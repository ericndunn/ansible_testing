#!/bin/bash

# Update CSC McDonald's image.

# There must be one command line argument: RAID or NORAID.
if [[ $# -lt 1 || ( "$1" != "RAID0" && "$1" != "RAID1" && "$1" != "RAID5" && "$1" != "RAID6" && "$1" != "NORAID" && "$1" != "HWRAID" ) ]] ; then
	echo "Usage $0: { RAID0 | RAID1 | RAID5 | RAID6 | NORAID | HWRAID } [[ PARTITION1 ] [ PARTITION 2 ] ... [ PARTITION N ]]"
	exit 
fi

if [[ ${1:0:4} == "RAID" ]]; then
	mode="RAID"
	raid_level=${1:4:1}

	for ((i=2;i<=$#;i++))
	do
		raid_parts+=(${!i})
	done

	if [[ ${#raid_parts[@]} -gt 0 ]]; then
		echo "======================================================================"
		echo " WARNING: You are manually specyfing the partitions to create a RAID"
		echo "======================================================================"
		echo ""
		echo " This script assumes that the following partitions already exist"
		echo " and the RAID flag has been set (sudo parted -s $device set 1 RAID on)"
		echo
		printf '    %s\n' "${raid_parts[@]}"
		echo
		echo " Press any key to continue ... "
		echo
		read
	fi
else
	mode="$1"
fi

failhard()
{
	echo "================================="
	echo "$1"
	echo "================================="
	cat
}

CURDIR=`dirname "$0"`
cd $CURDIR
SCRIPT_DIR=`pwd -L`

sudo service monit stop

if [[ $USER == "orchid" ]]; then
	if [[ $mode == "RAID" ]]; then
		# * (Re-)Build a Software RAID array

		# Unmount existing /orchives.
		sudo service orchid stop
		sudo umount /orchives

		# Kill existing RAID (if it exists).
		for device in `/bin/ls /dev/md*`
		do
			echo Killing $device
			sudo mdadm --stop $device
			sudo mdadm --remove $device

		#	while [[ -e $device ]]
		#	do
		#		echo Waiting for $device to go away ...
		#		sleep 5s
		#	done
		done

		# We'll say any block device >=1TB should be in the RAID.
		raid_devs=()
		if [[ ${#raid_parts[@]} -eq 0 ]]; then
			###
			# Automatically choose RAID drives/partitions	
			###
			raid_parts=()
			for device in `/bin/ls /dev/sd?`
			do 
				if [[ `sudo blockdev --getsize64 "$device"` -gt 1000000000000 ]]
				then 
					raid_devs+=("$device")
					raid_parts+=("${device}1")
				fi
			done

			# Reformat the >1TB drives (assume these will be in the RAID).
			for device in ${raid_devs[@]}
			do
				RET=1
					
				# Clear RAID metadata
				sudo dd if=/dev/zero of=$device bs=512 seek=$(( $(sudo blockdev --getsz $device) - 1024 )) count=1024
				sudo mdadm --zero-superblock --force ${device}

				sudo parted -s $device mklabel gpt
				sudo parted -s $device rm 1 > /dev/null
				sudo parted -s -- $device mkpart primary ext4 0% 100%
				sudo hdparm -z $device
				sudo parted -s $device set 1 RAID on
			done
		fi

		# Rebuild array.
		sudo mdadm --create --verbose /dev/md127 --assume-clean --level=${raid_level} --raid-devices=${#raid_parts[@]} ${raid_parts[@]}

		# Create ext4 filesystem on new array.
		sudo mkfs.ext4 /dev/md127

		# Set the array to start automatically.
		sudo cp /etc/mdadm/mdadm.conf /etc/mdadm/mdadm.conf.bak
		sudo bash -c "cat /etc/mdadm/mdadm.conf.bak | sed '/ARRAY/d' > /etc/mdadm/mdadm.conf"
		sudo bash -c "sudo mdadm --detail --scan >> /etc/mdadm/mdadm.conf"
		sudo update-initramfs -u

		# * Set fstab for RAID array
		sudo mv /etc/fstab /etc/fstab.bak
		sudo bash -c "cat /etc/fstab.bak | sed '/\/orchives/d' > /etc/fstab"
		UUID_STR=`sudo blkid -o export /dev/md127 | grep UUID`
		sudo bash -c "echo \"$UUID_STR /orchives auto nosuid,nodev,nofail 0 0\" >> /etc/fstab"

		# Verify /orchives is mounted
		sudo mkdir -p /orchives
		sudo umount /orchives
		sudo mount /orchives
		if ! mount | grep md127 | grep orchives &> /dev/null 
		then
			failhard "/orchives is not mounted"
		fi

		# * Verify Orchid has 2 TB available on storage volume
		if [[ `/bin/df --output=size /dev/md127 | egrep ^[0-9]+$` -lt 2721000028 ]]
		then
			failhard "/orchives looks too small"
		fi
	elif [[ $mode == "HWRAID" ]]; then
		# Setup a hardware RAID.  Assume that volume has already been initialized in the RAID BIOS.

		# We'll say any block device >=2TB is the hardware RAID volume.
		hwraid_device=""
		for device in `/bin/ls /dev/sd?`
		do 
			if [[ `sudo blockdev --getsize64 "$device"` -gt 2000000000000 ]]; then
				hwraid_device="$device"
			fi
		done

		if [[ -z "$hwraid_device" ]]; then
			failhard "Could not find a device that looks like a hardware RAID volume!"
		fi

		sudo parted -s $hwraid_device mklabel gpt
		sudo parted -s $hwraid_device rm 1 > /dev/null
		sudo parted -s -- $hwraid_device mkpart primary ext4 0% 100%
		sudo hdparm -z $hwraid_device

		
		hwraid_part="${hwraid_device}1"
		sudo mkfs.ext4 "$hwraid_part"

		# * Set fstab for RAID array
		sudo mv /etc/fstab /etc/fstab.bak
		sudo bash -c "cat /etc/fstab.bak | sed '/\/orchives/d' > /etc/fstab"
		UUID_STR=`sudo blkid -o export $hwraid_part | grep UUID`
		sudo bash -c "echo \"$UUID_STR /orchives auto nosuid,nodev,nofail 0 0\" >> /etc/fstab"

		# Verify /orchives is mounted
		sudo mkdir -p /orchives
		sudo umount /orchives
		sudo mount /orchives
		if ! mount | grep $hwraid_part | grep orchives &> /dev/null 
		then
			failhard "/orchives is not mounted"
		fi

		# * Verify Orchid has 2 TB available on storage volume
		if [[ `/bin/df --output=size $hwraid_part | egrep ^[0-9]+$` -lt 2721000028 ]]
		then
			failhard "/orchives looks too small"
		fi

	fi # end Hardware RAID section

	sudo service monit start
fi
