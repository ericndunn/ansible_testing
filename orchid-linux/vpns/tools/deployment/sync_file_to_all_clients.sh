#!/bin/bash

usage()
{
    echo "$0 FILE [IP LIST]"
    echo
    echo "rsync a file to all the clients on this server's VPN.  All rsyncs are performed"
    echo "in parallel."
    echo
    echo "  FILE   File to synchronize to all VPN clients' fusion_cloud_service home"
    echo "         directory."
    echo
}

if ! [[ -f "$1" ]]; then
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

declare -A transfers
failures=()

if [[ -z "$iplist" ]]; then
    iplist="$( /home/fusion/vpns/tools/monitoring/vpn_client_list.sh )"
fi

# Get the list of all VPN clients.
for line in $iplist; do 
    # We care only about their IP address.
    ip=$( cut -d , -f 1 <<< $line)

    # Transfer the file
    rsync -axv --partial --timeout=60 -e "ssh -o StrictHostKeyChecking=no -o BatchMode=yes -o ConnectTimeout=60" "$1" ${fusion_user}@${ip}: &
    transfers[$!]="$ip"
done

# Wait on all the PIDs we just spawned.
for pid in "${!transfers[@]}"; do
    wait $pid
    ret=$?

    # If the process returned an error, add the associated IP address to print out at the very end.
    if [[ $ret -ne 0 ]]; then
        failures+=("${transfers[$pid]},$ret")
    fi
done

# Print out the failures, if any.
if [[ ${#failures[@]} -gt 0 ]]; then
    echo "FAILED TRANSFERS (IP address, exit status):"
    echo "==========================================="
    for failure in "${failures[@]}"; do
        echo "$failure"
    done
else
    echo "ALL TRANSFERS SUCCESSFUL!"
fi
