#!/bin/bash

new_hostname="$1"


usage() 
{
    echo "$0 HOSTNAME"
    echo    
    echo "Configure an IPConfigure Cloud VM for logging in via FreeIPA."
    echo
    echo "       HOSTNAME    Should be of the form {name}.ipconfigure.colo"
    echo
    exit 1
}

if [[ "$EUID" -ne 0 ]]; then
    echo "ERROR: This script must be run as root."
    exit 1
fi

if [[ $# -ne 1 ]]; then
    usage
    exit 1
fi

new_hostname="$1"

printf "Using hostname $new_hostname. "
read -p "Continue? " -r ans
echo

if [[ ! "$ans" =~ ^[Yy]|yes|YES$ ]]; then
    echo Quitting.
    exit 1
fi

echo "${new_hostname}" > /etc/hostname
hostname "${new_hostname}"
cp /home/fusion/.bashrc /etc/skel
sed -i "/.*pam_mkhomedir.so.*/d" /etc/pam.d/common-session
echo "session required pam_mkhomedir.so skel=/etc/skel/" >> /etc/pam.d/common-session

apt install freeipa-client
ipa-client-install --mkhomedir
