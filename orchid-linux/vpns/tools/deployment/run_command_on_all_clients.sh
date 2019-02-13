#!/bin/bash

usage()
{
    echo "$0 COMMAND [IP LIST]"
    echo
    echo "Run a command via SSH on all VPN clients using the fusion_cloud_service user"
    echo "account.  The command is run on each server sequentially."
    echo
}


if [[ $# -lt 1 ]]; then
    usage
    exit 1    
fi

if [[ $# -eq 2 ]]; then
    if ! [[ -f "$2" ]]; then
        echo "Could not find $2"
        usage
        exit 1
    fi

    iplist="$( cat $2 )"
fi

fusion_user="fusion_cloud_service"

if [[ ! -z "$ALT_FUSION_USER" ]]; then
    fusion_user="$ALT_FUSION_USER"
fi

if [[ -z "$iplist" ]]; then
    iplist="$( /home/fusion/vpns/tools/monitoring/vpn_client_list.sh )"
fi

# Get the list of all VPN clients.
for line in $iplist; do
    # We care only about their IP address.
    ip=$( cut -d , -f 1 <<< $line)
    hostname=$( cut -d , -f 2 <<< $line)

    # Run the command
    echo --
    echo "$ip ($hostname)"
    ssh -t -o StrictHostKeyChecking=no -o BatchMode=yes -o ConnectTimeout=60 ${fusion_user}@${ip} "$1"
done
