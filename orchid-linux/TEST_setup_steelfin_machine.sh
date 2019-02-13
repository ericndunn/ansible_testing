#!/bin/bash

cd $( dirname "$0" )
script_dir=$( pwd -P )
orchid_install_dir="${script_dir}/orchid_install_files"

if [[ ! -f ${script_dir}/steelfin_common.sh ]]; then
    echo "Failed to load steelfin_common.sh"
    exit 1
fi

source ${script_dir}/steelfin_common.sh

# TODO: mkfs.ext4 optimized for SW RAID?
# TODO: RAID rebuild options

declare -A inline_file
inline_file[ro_git_key]="H4sIAEJWrVkAA22VN8+kaBCEc37F5mg1eBNs8OK9HxjI8AzeDG5+/X23l16nXS09KrWqfv/+GU6U
VeuX54NfjqeGIBB/6WL87+I3ZKqqOLsqB4DOA1cElFItHxlgYenRgfvNQwUJAWlZF03zb1BmzBXP
EfraHkwqNdbmQOjtu69VvD5pPT9l+Ny+j3IfpgJLYVahyNyjPIyLzoZrH5TQvXbzYlj3YpKtOIv7
lQzQt5tQuJBbrmMWAtfvc0LEsMnfREFi7t2XVXoZHrIlykDXeCzRjDlcXi3r7SoVyxX1EKOcCjsB
7LTD4vEYTzKwq8F1Y7/FLBTFk5P7TOscGGuw3tsgpLTWedmVUrs8MTgTe5DV9TuMTHrW6IJnRjhu
BI6MVPp2BOsk8CqBcDscTMX3QqWkTjTmscWnQ7nlF35O1UlDcl5frrshuQQ/8YFf6vbMNVtAxDNW
lls46D31n6cqABdwYPox2+Ur0yu4mUeuYOJYyOa8YvkmxocQZv5WLAIDLs11p5xdH+ebaF88KivG
I2sY9LOFsvhCtnGShh2+B+/soCDfwdKixAlzpmAUXiMQspNk9KeodjHcac68nTPTjqmlHrt461tv
n4Ijn/DFmwRHkBiExQvfnEhCtdf+zOVC6OS6J/AQFOZRmlMbPnrXQNlcOVgtfKcFwjgB/LIRKg2v
tg8OSBWMdz7oIaDob3E4RTSoNXN6sROnP7KYv+2ZGmIrjURhDUrK9kpiI7pyiY0g+XAIAYVKIylU
SEaqYlEgpXNr6xJPQ84A3htkY0qzmTday4TEeBZrR2Dp5OfVCe8fdkqdFwfB32sje6oBk8wBp9K7
zMq9wcuKYqTG2jwWF7ZkxEadR2WKzESf2CjkCmvs9Bs+F/MNCex6ig+SeUZj4Os+90G96MwerzMT
jJJ7V1t1OMzkCJaY+FtH/zyNmWXqsHL5s/Lb1wsK3juj8Gp23SkllQPsqLBgNxndIKDX1yCV8C7R
4zOtheZ1y5/RBOpsfYfrP2KwQklP2KMVSAyxWQL6McCB3SKcLMb9Rlb1ZDO4zr6tPqhGupjWg3hd
i1O5pZR/jfUDxhAiUeaJpOkxvDPdR7Le1JpNpj1sJg7/bp/IQAa6k5WR0CSZQLjjkmMiaWWIJlIN
ZooNtF+SI2yek9V5S2scdXB4cJJNzH6IcQoXIdqDaEV64S+ysR9v+sZfjymg9RpDQStBtw2G4VmP
e+i6EoPazY1agBJGVOT9hzu35UDfcKaCBYyThkbf9yXuV6zdoDmcunl0UF/bFrtuA8YPBlWYE07B
xbfh4qkiUMd7Z5ximMA2EfbaMQ83zO9Tk3dcZAH1XX7Cwoei7YkxZR/y4dCSQMeUipF4p+T+Itso
O3qU5uuc3G8HffIKaMO0CPArW4Du91tUQudVM+hyBNw9p1qQINWQVZGD9eC05koV0Gh0UEeyCzb/
cMQ9J7ihMNeLP0dVurqUUSBLHY/0cj8l8HH/1ou1id5nC3eMMs2a5/S0c9wfTGLcemsah2wOGh7Y
H01O7PCgjTY0T8FjbEbrBxnIP6d7bJ8Gah+ulOtvXX/ZEU0FAzGFGTFPpMO7C6BpRVeq/JFWSfOA
8h1NBMF9ZtGuj6eKfqLQRFx7qRY1VvQSf3bOtsvjd5MENAxfl5bkMLl7KXsSr+7WR8gfkrU5YGMs
BbluFMvB6VK7wvDJw6vh+P6rQL297peIOEh/SkhkzUDXM3+gv7UiWsL/180/BZBEU48GAAA="

inline_file[debian_preseeds]=\
"postfix postfix/main_mailer_type string No configuration
ipc-orchid ipc-orchid/accept_eula boolean true
ipc-orchid ipc-orchid/accept_eula2 boolean true
ipc-orchid ipc-orchid/admin_password string 0rc#1d
ipc-orchid ipc-orchid/webserver_port string 80
ipc-orchid ipc-orchid/orchives_dir string /orchives
ipc-orchid ipc-orchid/autodiscovery_ip_address string 127.0.0.1"

# Configure some useful variables that will vary depending on the OS type.
configure_os_variables() {
    # Set some defaults for Ubuntu 14.04, then change as necessary.
    mdadm_conf="/etc/mdadm/mdadm.conf"
    pkg_type="deb"

    if [[ $distro_id == "CentOS" ]] || [[ $distro_id == "RedHatEnterpriseLinuxServer" ]] ;then
        mdadm_conf="/etc/mdadm.conf"
        pkg_type="rpm"
    fi
}

# Get on my level.
usage() {
    echo "Usage $0: <SERIAL> <MODE> [PARTITION_LIST]"
    echo
    echo "Configure a SteelFin Linux server for use with Orchid Core.  This includes"
    echo "configuring a software RAID (as necessary), installing IPConfigure/Orchid "
    echo "branding, and the Orchid Core installer."
    echo
	echo " SERIAL - IPConfigure SteelFin server serial number"
    echo "   MODE - Specify how to configure the server's /orchive directory.  This value"
    echo "          must be one of the following:"
    echo 
    echo "          UPDATE: Update to the latest version of this script from Github."
    echo "           RAID0: Configure all hard drives >= 1TB as a software RAID 0"
    echo "                  device /dev/md125 mounted at /orchives."
    echo "           RAID1: As above, but RAID1."
    echo "           RAID5: As above, but RAID5."
    echo "           RAID6: As above, but RAID6."
    echo "          NORAID: Configure the /orchives directory on the root storage device."
    echo "          HWRAID: Configure the /orchives directory on a hardware RAID device."
    echo
    echo " PARTITION_LIST - If specified, do not attempt to auto-detect suitable software"
    echo "                  RAID partitions, and instead use the provided list.  Do not"
    echo "                  use this unless you really know what you're doing."
    echo
    exit 1
}

# Verify that the command line parameters are syntactically valid.
verify_cmdline_parameters() {
	serial="$1"
    mode="$2"
    valid_modes=( "RAID0" "RAID1" "RAID5" "RAID6" "NORAID" "HWRAID" "UPDATE" )

    # Verify a valid mode was specified. 
    if [[ $# -lt 2 ]] || ! grep -P "${mode}( |$)" &> /dev/null <<< ${valid_modes[@]} ; then
        usage
    fi

    # For the RAID modes, parse out the RAID type.
    if [[ ${mode:0:4} == "RAID" ]]; then
        raid_level=${mode:4:1}
        mode="SWRAID"

        # If any additional arguments were specified, they must be a list of RAID partitions.
        for ((i=3;i<=$#;i++)); do
            raid_parts+=(${!i})
        done

        # If you've specified the RAID partitions, let's hope you know what you're doing.
        if [[ ${#raid_parts[@]} -gt 0 ]]; then
            echo "======================================================================"
            echo " WARNING: You are manually specyfing the partitions to create a RAID"
            echo "======================================================================"
            echo ""
            echo " This script assumes that the following partitions already exist"
            echo " and the RAID flag has been set (sudo parted -s $device set 1 RAID on)"
            echo
            printf '    %s\n' "${raid_parts[@]}" | fold -w 80 -s
            echo
            echo " Press any key to continue, or Ctrl-C to quit ... "
            echo
            read
        fi
    fi    
}

# Pull down the latest version of the script from the IPConfigure's Github integrations repo.
script_update() {
    trap die_with_error ERR

    # Install Git.
    if [[ $distro_id == "Ubuntu" ]]; then
        sudo apt-get update
        sudo apt-get -y install git
    else
        # PackageKit on CentOS will block RPM (seemingly forever) while you're trying to
        # manually install packages.  Kill it.
        sudo systemctl stop packagekit.service 

        sudo yum -y install epel-release
        sudo rpm -Uvh --force http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-1.el7.nux.noarch.rpm
        sudo yum -y update
        sudo yum -y install git
    fi

    # Put our read-only SSH public key in place, run Git, then remove ours and restore the old one.

    # Backup existing key
    mkdir -p ~/.ssh
    if [[ -f ~/.ssh/id_rsa ]]; then
        mv ~/.ssh/id_rsa ~/.ssh/id_rsa.orchid.bak
    fi

    # Extract our key
    base64 -id <<< "${inline_file[ro_git_key]}" | gunzip > ~/.ssh/id_rsa 
    chmod 600 ~/.ssh/id_rsa
    chown -R ${effective_user}.${effective_user} ~/.ssh

    # Git the goods.
    git fetch --all
    git checkout master
    git reset --hard origin/master

    # Restore the old key.
    rm -f ~/.ssh/id_rsa
    if [[ -f ~/.ssh/id_rsa.orchid.back ]]; then
        mv -f ~/.ssh/id_rsa.orchid.bak ~/.ssh/id_rsa
    fi
}

# Install prerequisites software packages.
install_orchid_prereqs() {
    trap die_with_error ERR

    if [[ $distro_id == "Ubuntu" ]] && [[ $distro_release == "16.04" ]]; then
        # Install preseed answers for Debian packages
        preseeds=$( write_var_to_tmp "${inline_file[debian_preseeds]}" )
        debconf-set-selections ${preseeds}
        rm -f ${preseeds}

        # * Install VLC and SSH
        apt-get update
        apt-get -y upgrade
        #apt-get -y install vlc expect gdebi ssh jq mdadm smartmontools zenity curl wget
        # Install the HWE kernel on 16.04 to support the 2nd NIC on H370N0-WIFI motherboards
        apt-get -y install --install-recommends linux-generic-hwe-16.04 xserver-xorg-hwe-16.04
    elif [[ $distro_id == "Ubuntu" ]] && [[ $distro_release == "18.04" ]]; then
        # Install preseed answers for Debian packages
        preseeds=$( write_var_to_tmp "${inline_file[debian_preseeds]}" )
        debconf-set-selections ${preseeds}
        rm -f ${preseeds}

        # * Install VLC and SSH
        #apt-get -y remove gdm3 ubuntu-session
        apt-get -y update
        apt-get -y upgrade
        #apt-get -y install vlc expect gdebi ssh jq mdadm smartmontools zenity curl wget unity lightdm
        # Install the HWE kernel on 16.04 to support the 2nd NIC on H370N0-WIFI motherboards
        apt-get -y install --install-recommends linux-generic-hwe-16.04 xserver-xorg-hwe-16.04
        # service gdm stop
        # service lightdm stop
        # service lightdm start             
    else 
        # PackageKit on CentOS will block RPM (seemingly forever) while you're trying to
        # manually install packages.  Kill it.
        systemctl stop packagekit.service 

        # Install script prereqs
        yum -y install epel-release
        rpm -Uvh --force http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-1.el7.nux.noarch.rpm
        yum -y update
        yum -y install tbb postgresql-libs vlc expect jq mdadm lsb curl libXScrnSaver.x86_64 hdparm
    fi

}

# Download Orchid from the website (if required), and validate it against an MD5 hash.
download_orchid() {
    # If ORCHID_VERSION is specified as an environment variable, use it.  Otherwise,
    # use the version that the website reports as LATEST.
    orchid_version=$ORCHID_VERSION
    if [[ -z $orchid_version ]]; then
        orchid_version=$(curl -s "http://192.168.100.205/orchid/LATEST")
    fi

    if [[ $distro_id == "Ubuntu" ]] && [[ $distro_release == "16.04" ]]; then
        pkg_ext="-jessie"
    elif [[ $distro_id == "Ubuntu" ]] && [[ $distro_release == "18.04" ]]; then
        pkg_ext="-bionic"        
    fi

    # Verify we have the latest Orchid installer
    orchid_pkg="ipc-orchid-x86_64_${orchid_version}${pkg_ext}.${pkg_type}"
    if [[ ! -f ${orchid_install_dir}/${orchid_pkg} ]]; then
        rm -f ${orchid_install_dir}/ipc-orchid-x86_64_*.${pkg_type}
            
        # Download installer
        if ! wget -O ${orchid_install_dir}/${orchid_pkg} \
                  http://192.168.100.205/orchid/${orchid_pkg} ; then
            die_with_error "COULD NOT DOWNLOAD ORCHID INSTALLER"
        fi

        # Download checksum
        if ! wget -O ${orchid_install_dir}/${orchid_pkg}.md5 \
                  http://192.168.100.205/orchid/${orchid_pkg}.md5 ; then
            die_with_error "COULD NOT DOWNLOAD ORCHID INSTALLER MD5 HASH"
        fi
        
    fi

    # Verify checksum
    pushd . > /dev/null ; cd ${orchid_install_dir}
    if ! md5sum -c ${orchid_pkg}.md5 &> /dev/null ; then
        rm -f ${orchid_install_dir}/${orchid_pkg}
        rm -f ${orchid_install_dir}/${orchid_pkg}.md5
        die_with_error "DOWNLOADED ORCHID INSTALLER FAILED MD5 HASH"
    fi
    popd > /dev/null
}

install_browser() {
    trap die_with_error ERR

    if [[ $distro_id == "Ubuntu" ]]; then
        if [[ $distro_release == "14.04" ]]; then
            # Install Chrome
            gdebi -n ${orchid_install_dir}/google-chrome-stable_34.0.1847.137-1_amd64.deb
            
            # Chrome 34's APT repo is not currently valid, and we don't want to ever update
            # anyway, so...
            sudo rm -f /etc/apt/sources.list.d/google-chrome.list

            # Downgrade libnss3 so that Chrome 34 works.  This is not clean.
            trap ERR
            apt-get -y install libnss3-nssdb
            apt-get -y install libnss3
            apt-get -y install libnss3-tools

            dpkg -i --force-downgrade ${orchid_install_dir}/libnss3-nssdb_3.15.4-1ubuntu7_all.deb  
            dpkg -i --force-downgrade ${orchid_install_dir}/libnss3_3.15.4-1ubuntu7_amd64.deb
            dpkg -i --force-downgrade ${orchid_install_dir}/libnss3-tools_3.15.4-1ubuntu7_amd64.deb
            trap die_with_error ERR

            # Prevent Chrome upgrades
            apt-mark hold google-chrome-stable
            apt-mark hold libnss3-nssdb
            apt-mark hold libnss3
            apt-mark hold libnss3-tools

        elif [[ $distro_release == "16.04" ]] || [[ $distro_release == "18.04" ]]; then
            add-apt-repository -y ppa:jonathonf/firefox-esr-52
            apt-get update
            apt-get -y install firefox-esr

            apt-mark hold firefox-esr
            # Install Chrome
            wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - 
            sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
            apt-get -y update
            apt-get -y install google-chrome-stable            
        else
            die_with_error "ERROR: Unknown \$distro_release: $distro_release"
        fi
    elif [[ $distro_id == "CentOS" ]] || [[ $distro_id == "RedHatEnterpriseServer" ]]; then
        # Install Chrome
        rpm -Uvh --force ${orchid_install_dir}/google-chrome-stable-34.0.1847.137-1.x86_64.rpm

        # Prevent Chrome upgrades
        sed -i '/exclude=.*/d' /etc/yum.conf
        echo 'exclude=google-chrome-stable*' >> /etc/yum.conf

        # Make plugins work
        setsebool -P unconfined_mozilla_plugin_transition 0
    else
        die_with_error "ERROR: Unknown \$distro_id: $distro_id"
    fi
}

setup_serial_number() {
    echo "orchid-${serial}" > /etc/hostname
    sed -i "s/^127\\.0\\..*orchid.*/127.0.0.1 orchid-${serial}/" /etc/hosts
    echo "${serial}" > /etc/steelfin-serial-number

    sed -i "s/^127\.0\.0\.1.*/127.0.0.1 localhost orchid-${serial}/" /etc/hosts

    if [[ $distro_id == "Ubuntu" ]] && [[ $distro_release == "14.04" ]]; then
        service hostname start
    fi
}

install_teamviewer() {
    trap die_with_error ERR

    pushd . > /dev/null ; cd /opt
    tar xvfz ${orchid_install_dir}/TeamViewerQS.tar.gz
    mkdir -p /opt/teamviewerqs/tv_bin/desktop/
    touch /opt/teamviewerqs/tv_bin/desktop/teamviewer.desktop.template
    popd > /dev/null
    cp ${orchid_install_dir}/teamviewer.png /opt/teamviewerqs/tv_bin/desktop/

    if [[ $distro_id == "Ubuntu" ]]; then
        sudo update-icon-caches /usr/share/icons/*
        sudo update-icon-caches /opt/teamviewerqs/tv_bin/desktop/*
    fi

    # Fix TeamViewer on Red Hat.
    if [[ $distro_id == "CentOS" ]] || [[ $distro_id == "RedHatEnterpriseServer" ]]; then
        rpm -Uvh --force ${orchid_install_dir}/patchelf-0.8-2.sdl7.x86_64.rpm
        cp ${orchid_install_dir}/redhat/tvw_exec /opt/teamviewerqs/tv_bin/script
        cp /usr/bin/patchelf /opt/teamviewerqs/tv_bin/RTlib
    fi
}

# Check if /orchives is mounted.  Suppress all output; result is $?.
orchives_mounted() {
    cat /proc/self/mounts | tr -s ' ' | cut -d ' ' -f 2 | grep '^/orchives' &> /dev/null
}

# Look for "$1" in a list of all configured system services.  Suppress all output;
# result is $?.
service_exists() {
    if [[ $distro_id == "Ubuntu" ]] && [[ $distro_release == "14.04" ]]; then
        service --status-all 2>&1 | tr -s ' ' | cut -d ' ' -f 5 | grep "^${1}" &> /dev/null
    else
        systemctl list-unit-files | grep enabled | tr -s ' ' | cut -d ' ' -f 1 | grep "^${1}.service" &> /dev/null
    fi
}

# Run a command on a service using "service" or "systemctl" as appropriate.
service_command() {
    service_name="$1"
    service_command="$2"

    if [[ $distro_id == "Ubuntu" ]] && [[ $distro_release == "14.04" ]]; then
        service ${service_name} ${service_command}
    else
        systemctl ${service_command} ${service_name} 
    fi
}

# Set the specified device to mount at /orchives, then verify /orchives is
# mounted and a reasonable size.
set_orchives_fstab_and_verify() {
    trap die_with_error ERR

    device="$1"

    # This is in bytes ... we'll divide by 1024 later since df wants KB.
    minimum_orchives_size=$(( 2 * 2**40 ))

    # * Set fstab for RAID array
    mv /etc/fstab /etc/fstab.bak
    cat /etc/fstab.bak | sed '/\/orchives/d' > /etc/fstab
    UUID_STR=$(blkid -o export ${device} | grep ^UUID)
    echo "$UUID_STR /orchives auto nosuid,nodev,nofail 0 0" >> /etc/fstab
    
    # Verify /orchives is mounted
    mkdir -p /orchives
    if orchives_mounted; then
        umount /orchives
    fi
    
    # With /orchives unmounted, make the directory (on the root partition) immutable.
    # If the RAID won't mount, we don't want to write to the root partition, we just want to fail.
    chattr +i /orchives

    mount /orchives
    if ! mount | grep ${device} | grep orchives &> /dev/null ; then
        die_with_error "/orchives is not mounted"
    fi

    # Verify Orchid has so much available on storage volume. Anything smaller than this indicates 
    # something is wrong with the RAID.
    if [[ `/bin/df --output=size ${device} | egrep ^[0-9]+$` -lt $(( $minimum_orchives_size / 1024 )) ]]; then
        die_with_error "/orchives looks too small"
    fi
}
stop_orchid_and_unmount_orchives() {
    trap die_with_error ERR
    
    # Stop orchid if it exists.
    if service_exists "orchid"; then
        service_command "orchid" "stop"
    fi

    if orchives_mounted; then
        umount /orchives
    fi
}

setup_software_raid() {
    trap die_with_error ERR

    stop_orchid_and_unmount_orchives

    # Kill existing RAID (if it exists).
    for device in $(/bin/ls /dev/md*); do
        echo Killing $device
        # "Best effort" stop the RAID.
        trap ERR
        mdadm --stop $device
        mdadm --remove $device
        trap die_with_error ERR
    done

    # If raid_parts weren't specified on the command line, we'll build them here by
    # assuming any block device >=1TB should be in the RAID.
    raid_devs=()
    if [[ ${#raid_parts[@]} -eq 0 ]]; then
        # Automatically choose RAID drives/partitions    
        raid_parts=()

        # Assume anything greater than 900GB should be a RAID member.  Size below is in bytes.
        raid_size_threshold=$(( 900 * 2**30 ))
        for device in $(/bin/ls /dev/sd?); do 
            if [[ $(blockdev --getsize64 "$device") -gt $raid_size_threshold ]]; then 
                raid_devs+=("$device")
                raid_parts+=("${device}")
            fi
        done

        # Reformat the >1TB drives (assume these will be in the RAID).
        for device in ${raid_devs[@]}; do
            # Clear RAID metadata
            dd if=/dev/zero of=$device bs=512 seek=$(( $(blockdev --getsz $device) - 1024 )) count=1024
            dd if=/dev/zero of=$device bs=1M count=10
            mdadm --zero-superblock --force ${device}
        done
    fi

    # Rebuild array.
    mdadm --create --verbose /dev/md125 --assume-clean --level=${raid_level} --raid-devices=${#raid_parts[@]} ${raid_parts[@]}

    # Create ext4 filesystem on new array.
    mkfs.ext4 -m 0 /dev/md125

    # Set the array to start automatically.
    cp ${mdadm_conf} ${mdadm_conf}.bak
    cat ${mdadm_conf}.bak | sed '/ARRAY/d' > ${mdadm_conf}
    mdadm --detail --scan >> ${mdadm_conf}
    update-initramfs -u

    # Verify our /orchives partition auto-mounts and is reasonably sized.
    set_orchives_fstab_and_verify "/dev/md125"

    # Configure RAID monitoring
    write_raid_monitor_script /usr/local/bin/orchid_raid_notify.sh
    sed -i '/MAILFROM.*/d' ${mdadm_conf}
    sed -i '/MAILADDR.*/d' ${mdadm_conf}
    sed -i '/PROGRAM.*/d' ${mdadm_conf}
    echo 'PROGRAM /usr/local/bin/orchid_raid_notify.sh' \
        >> ${mdadm_conf}

    # Add minutely cronjob to run RAID monitor tool
    crontab -l \
        | sed '/.*orchid_raid_notify.sh.*/d' \
        | printf "* * * * * /sbin/mdadm --monitor --scan --oneshot\n" \
        | crontab -

    # Set up a reasonable RAID rebuild speed.  By default,
    # the minimum RAID rebuild speed is very fast and will
    # choke Orchid.  We want the automatic rebuild speed
    # pretty slow.  If you're manually rebuilding, you can 
    # override this with systctl -w dev.raid.speed_limit_max=whatever
    sed -i '/dev.raid.speed_limit_max.*/d' /etc/sysctl.conf
    echo "dev.raid.speed_limit_max = 50000" >> /etc/sysctl.conf
    sysctl -p
}

# Setup a hardware RAID.  Assume that volume has already been initialized in the RAID BIOS.
setup_hardware_raid() {
    trap die_with_error ERR

    if ! mount | grep orchives &> /dev/null ; then
        stop_orchid_and_unmount_orchives
        # We'll say any block device >=2TB is the hardware RAID volume.
        hwraid_device=""
        hwraid_minimum_size=$(( 2 * 2**40 ))
        for device in $(/bin/ls /dev/sd?); do 
            if [[ $(blockdev --getsize64 "$device") -gt ${hwraid_minimum_size} ]]; then
                hwraid_device="$device"
            fi
        done

        if [[ -z "$hwraid_device" ]]; then
            die_with_error "Could not find a device that looks like a hardware RAID volume!"
        fi

        # Create partition and filesystem on detected HWRAID device.
        parted -s $hwraid_device mklabel gpt
        parted -s $hwraid_device rm 1 > /dev/null || true
        parted -s -- $hwraid_device mkpart primary ext4 0% 100%
        hdparm -z $hwraid_device
        
        hwraid_part="${hwraid_device}1"
        mkfs.ext4 -m 0 "$hwraid_part"

        set_orchives_fstab_and_verify ${hwraid_part}
    fi

    # Install maxView Storage Manager
    if [[ ! -f /usr/StorMan ]]; then
        storman_archive="msm_linux_x64_v2_04_22665.tgz"
        mkdir tmp
        pushd .
        cd tmp
        wget "http://192.168.100.205/orchid/extra/${storman_archive}"
        tar xvfz ${storman_archive}
        cd manager
        if [[ $distro_id == "Ubuntu" ]]; then
            gdebi StorMan*amd64.deb
        else
            rpm -Uvh --force StorMan*.x86_64.rpm
        fi
        popd
        rm -rf tmp
    fi
}

# Install the Debian or RPM packaged specified by $1.
install_package() {
    trap die_with_error ERR
    package="$1"

    if [[ $distro_id == "Ubuntu" ]]; then
        gdebi -n "${package}"
    elif [[ $distro_id == "RedHatEnterpriseServer" ]] || [[ $distro_id == "CentOS" ]]; then
        rpm -Uvh --force "${package}"
    else
        die_with_error "ERROR: Unknown distibution ${distro_id}"
    fi
}

install_orchid() {
    trap die_with_error ERR
    
    install_package "${orchid_install_dir}/${orchid_pkg}"

### COMMENT OUT fbgst_pkg TILL FIX IMPLEMENTED ###
    # fbgst_pkg=$(find /opt/orchid/share/orchid-html/ | grep -E "FBGST_[.0-9]+.${pkg_type}$")
    # if [[ ! -f $fbgst_pkg ]]; then
    #     failhard "ERROR: Could not find FBGST installer in orchid directory." 
    # fi     

    # install_package "${fbgst_pkg}"

    # Red Hat requires some manual installation steps.
    if [[ $distro_id == "RedHatEnterpriseServer" ]] || [[ $distro_id == "CentOS" ]]; then
        cp /opt/orchid/orchid_server.properties.default /etc/opt/orchid_server.properties
        
        # Set some Orchid properties (remove them first in case they exist)
        sed -i '/orchid.admin.password =.*/d'  /etc/opt/orchid_server.properties
        sed -i '/rtsp.rtp_port.* =.*/d' /etc/opt/orchid_server.properties

        echo 'orchid.admin.password = 0rc#1d' >> /etc/opt/orchid_server.properties
        echo 'rtsp.rtp_port_range.min = 40000' >> /etc/opt/orchid_server.properties
        echo 'rtsp.rtp_port_range.min = 50000' >> /etc/opt/orchid_server.properties

        sed -i '/archives.dir =.*/d'  /etc/opt/orchid_server.properties
        echo 'archives.dir = /orchives' >> /etc/opt/orchid_server.properties
        
        # Enable and Start orchid services
        systemctl enable orchid.service
        systemctl enable orchid_onvif_autodiscovery.service
        systemctl start orchid.service
        systemctl start orchid_onvif_autodiscovery.service
    fi

    if [[ $mode == "SWRAID" ]] || [[ $mode == "HWRAID" ]]; then
        sed -i '/^archivecleaner.usedspace.percentage = .*/d' /etc/opt/orchid_server.properties
        printf "\narchivecleaner.usedspace.percentage = 98\n" >> /etc/opt/orchid_server.properties
    fi
}

configure_firewall() {
    if [[ $distro_id == "RedHatEnterpriseServer" ]] || [[ $distro_id == "CentOS" ]]; then
        # Firewall settings
        sudo firewall-cmd --zone=public --add-port=80/tcp --permanent
        sudo firewall-cmd --zone=public --add-port=554/tcp --permanent
        sudo firewall-cmd --zone=public --add-port=40000-50000/udp --permanent
        sudo firewall-cmd --zone=public --add-port=5565/tcp --permanent
        sudo firewall-cmd --zone=public --permanent --add-service=ssh
        sudo firewall-cmd --reload
    fi
}

# Disable the things that will frighten and confuse our tender, innocent users.
# These include things like automatic update notifications.
disable_nonsense() {
    trap die_with_error ERR

    if [[ $distro_id == "Ubuntu" ]]; then
        # Remove update-notifier, disable notifications
        apt-get -y remove update-notifier
        sed -i "s/^/#/"   "/etc/apt/apt.conf.d/99update-notifier"
        sed -i "s/^##/#/" "/etc/apt/apt.conf.d/99update-notifier"

        # * Disable apport
        sudo sed -i '/enabled=.*/d' /etc/default/apport
        echo "enabled=0" >> /etc/default/apport
        service_command "apport" "restart"

       # Disable guest account
        printf "[SeatDefaults]\nallow-guest=false" > /etc/lightdm/lightdm.conf

    elif [[ $distro_id == "RedHatEnterpriseServer" ]] || [[ $distro_id == "CentOS" ]]; then
        # Disable automatic upgrades
        sudo systemctl disable packagekit.service
        sudo systemctl stop packagekit.service
    else
        die_with_error "ERROR: Unknown distribution ${distro_id}."
    fi
}

install_ntp_server() {
    trap die_with_error ERR

    if [[ $distro_id == "Ubuntu" ]]; then
        apt-get -y install ntp
        apt-get -y remove ntpdate
        cat > /etc/ntp.conf << EOF
server 127.127.1.0 prefer
fudge 127.127.1.0 stratum 10
driftfile /var/lib/ntp/drift
broadcastdelay 0.008
restrict 127.0.0.1
restrict 192.168.2.0 mask 255.255.255.0 nomodify notrap
EOF

        service_command "ntp" "restart"
    fi
}

apply_branding() {
    trap die_with_error ERR
    
    if [[ $distro_id == "Ubuntu" ]]; then
        cp ${orchid_install_dir}/poweredby_ipconfigure.png /usr/share/pixmaps/
        cp ${orchid_install_dir}/orchid_background.jpg /usr/share/pixmaps/
        cp ${orchid_install_dir}/orchid_background_blank.png /usr/share/pixmaps/

        # The following block won't work over SSH. 
        trap ERR
        xhost +SI:localuser:lightdm
        su lightdm -s /bin/bash << EOF
gsettings set com.canonical.unity-greeter logo /usr/share/pixmaps/poweredby_ipconfigure.png
gsettings set com.canonical.unity-greeter background /usr/share/pixmaps/orchid_background_blank.png
gsettings set com.canonical.unity-greeter draw-grid false
gsettings set com.canonical.unity-greeter draw-user-backgrounds false
gsettings set com.canonical.unity-greeter idle-timeout 0
EOF
        trap die_with_error ERR

    elif [[ $distro_id == "CentOS" ]] || [[ $distro_id == "RedHatEnterpriseServer" ]]; then
        yum -y remove gnome-shell-extension-window-list
        yum -y install gnome-shell-extension-dash-to-dock

        # Set login screen background
        cp ${orchid_install_dir}/orchid_background_blank.png \
            /usr/share/gnome-shell/theme/noise-texture.png
        cp ${orchid_install_dir}/poweredby_ipconfigure.svg /usr/share/pixmaps/
        cp ${orchid_install_dir}/redhat/etc/dconf/db/gdm.d/01-logo /etc/dconf/db/gdm.d/01-logo
        cp ${orchid_install_dir}/redhat/etc/dconf/profile/gdm /etc/dconf/profile/gdm
        dconf update
    else
        die_with_error "ERROR: Unknown distribution ${distro_id}"
    fi
}

configure_network() {
    if [[ $distro == "CentOS" ]] || [[ $distro == "RedHatEnterpriseServer" ]]; then
        # Start all network interfaces at boot up
        for file in `/bin/ls /etc/sysconfig/network-scripts/ifcfg-*`; do 
            sudo sed -i "s/ONBOOT=.*/ONBOOT=yes/" $file
        done
    fi
}

write_raid_monitor_script() {
    cat << EOF > "$1"
#!/bin/bash

raid_device=/dev/md125

notify_all() {
    if [[ -f /etc/redhat-release ]]; then
        notify_redhat "$@"
    elif [[ -f /etc/debian_version ]]; then
        notify_ubuntu "$@"
    fi
}

notify_ubuntu() {
    local notify_opts="$1"
    local title="$2"
    local msg="$3"
    local popup=$4

    who | rev | uniq -f 5 | rev | awk '{print $1, $NF}' | tr -d "()" |
    while read u d; do
        id=$(id -u $u)
        . /run/user/$id/dbus-session 2> /dev/null
        export DBUS_SESSION_BUS_ADDRESS
        export DISPLAY=$d
        su $u -c "/usr/bin/notify-send $notify_opts '$title' '$msg'"

        if [[ $popup -gt 0 ]]; then
            # If there are any open zenity dialogs, kill them now
            for zenity_pid in $(ps auwx | grep "su $u" | grep zenity | tr -s ' ' | cut -d ' ' -f 2); do
                kill $zenity_pid
            done
            su $u -c "/usr/bin/zenity --error --text '<b>$title</b>\n\n$msg'" &
        fi
    done
}

notify_redhat() {
    true
}

status="$1"

if [[ $status == "DegradedArray" ]]; then
    # Is RAID rebuilding?
    if sudo mdadm --detail ${raid_device} | grep "Rebuild Status" &> /dev/null; then
        notify_opts="-t 10000 \
            -u critical \
            -c device.error \
            -i /usr/share/icons/HighContrast/48x48/devices/drive-harddisk.png"
        title="Video Storage is Rebuilding"
        em_sp=" "
        details="$(sudo mdadm --detail ${raid_device} | egrep 'Rebuild Status' | sed "s/%/％/g")"
        msg="$(printf "Your Orchid server RAID array is rebuilding.\n${em_sp}""
${details}")"
        popup=0
    else
        # RAID is failed
        notify_opts="-t 10000 \
            -u critical \
            -c device.error \
            -i /usr/share/icons/HighContrast/48x48/status/computer-fail.png"
        title="Critical Video Storage Error!"
        em_sp=" "
        details="$(sudo mdadm --detail ${raid_device} | egrep '(State :|(Raid|Working) Devices)' | sed 's/^[ \t]*//g')"
        msg="$(printf "Your Orchid server RAID (video storage hard drive) array is degraded.\n${em_sp}\nPlease contact your video server service provider <b>immediately</b> to avoid data loss!\n${em_sp}\n${details}")"
        popup=1
    fi
fi

notify_all "$notify_opts" "$title" "$msg" $popup
EOF
    chmod 755 "$1"   
}

effective_user=$USER
if [[ ! -z $SUDO_USER ]]; then
    effective_user=${SUDO_USER}
fi

if [[ $effective_user != "orchid" ]]; then
    die_with_error "ERROR: You are running this script as \"$effective_user\".  It really doesn't do anything unless you are user \"orchid\"."
fi

verify_steelfin_os
configure_os_variables
verify_cmdline_parameters "$@"

if [[ -z $IPC_CONFIG_SCRIPT_RAID_ONLY ]]; then
    if [[ $mode == "UPDATE" ]]; then
        verify_unrootness
        script_update
        exit 0
    fi

    verify_rootness
    install_orchid_prereqs
    download_orchid
    install_browser
    install_teamviewer
fi

	setup_serial_number

if [[ $mode == "SWRAID" ]]; then
    setup_software_raid
elif [[ $mode == "HWRAID" ]]; then
    setup_hardware_raid
fi

if [[ -z $IPC_CONFIG_SCRIPT_RAID_ONLY ]]; then
    install_orchid
    configure_firewall
    install_ntp_server
    disable_nonsense
    apply_branding
    configure_network
fi

show_message "SUCCESSFULLY COMPLETED!"
