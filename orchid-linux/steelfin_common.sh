#!/bin/bash

# A collection of commonly used functions by IPConfigure SteelFin/VPN scripts.

show_message() {
    printf '=%.0s' {1..80} ; echo
    fold -w 80 -s <<< "$1"
    printf '=%.0s' {1..80} ; echo
}

# Print an error message and exit with failure status.
die_with_error() {
    ERR="$1"
    if [[ -z $ERR ]]; then
        ERR="Something went wrong!"
    fi
    show_message "$ERR"
    exit 1
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    die_with_error "ERROR: This script cannot be called directly.  It's designed to be sourced by other IPConfigure scripts."
fi

# Helper function write a bash variable to a file. 
write_var_to_tmp() {
    tmpfile=$( mktemp )
    echo "${inline_file[debian_preseeds]}" > $tmpfile
    echo $tmpfile
}

# This script will only run as root.  If we're not root, die with an error.
verify_rootness() {
    if [[ $EUID -ne 0 ]]; then
        die_with_error "This script must be run as root."
    fi
}

# This script should NOT run as root.  If we're root, die with an error.
verify_unrootness() {
    if [[ $EUID -eq 0 ]]; then
        die_with_error "This script must NOT be run as root."
    fi
}

# Verify that the script is running on a support Linux distribution and version.
verify_steelfin_os() {
    # lsb_release will always be available on Ubuntu.  It is available on RHEL/CentOS 
    # only through the package redhat-lsb-core.
    if which lsb_release &> /dev/null ; then
        distro_id=$(lsb_release -is)
        distro_release=$(lsb_release -rs)

        # First verify the distro_id is valid, then check distro_release.
        if [[ $distro_id == "Ubuntu" ]]; then
            if [[ $distro_release != "14.04" ]] && [[ $distro_release != "16.04" ]] && [[ $distro_release != "18.04" ]]; then
                die_with_error "Unsupported Ubuntu version ${distro_release}.  Only 14.04, 16.04, and 18.04 are supported."
            fi
        elif [[ $distro_id == "CentOS" ]]; then
            if ! grep '^7\..*' &> /dev/null <<< $distro_release ; then
                die_with_error "Unsupported CentOS version ${distro_release}.  Only 7.x is supported."
            fi 
        elif [[ $distro_id == "RedHatEnterpriseServer" ]]; then
            if ! grep '^7\..*' &> /dev/null <<< $distro_release ; then
                die_with_error "Unsupported RHEL version ${distro_release}.  Only 7.x is supported."
            fi
        else
            die_with_error "Unsupported distribution type ${distro_id}.  Only Ubuntu, CentOS, and RedHatEnterpriseServer are supported."
        fi
    elif [[ -f /etc/redhat-release ]]; then
        # If lsb_release isn't available, the only supported OS this could be is Red Hat.
        if grep '^CentOS Linux' &> /dev/null < /etc/redhat-release ; then
            distro_id="CentOS"
        elif grep '^Red Hat Enterprise Linux' &> /dev/null < /etc/redhat-release ; then
            distro_id="RedHatEnterpriseServer"
        else
            die_with_error "Unsupported Red Hat variant, only RHEL and CentOS are supported: $( cat /etc/redhat-release )"        
        fi

        distro_release=$( cat /etc/redhat-release | grep -oE "release 7.[.0-9]+" | sed 's/release //' )
        if [[ -z $distro_release ]]; then
            die_with_error "Unsupported Red Hat version, only RHEL and CentOS 7.x are supported: $( cat /etc/redhat-release )"
        fi
    else
        die_with_error "Unsupported OS.  This distribution doesn't look like RHEL 7, CentOS 7, Ubuntu 14, or Ubuntu 16."
    fi     
}