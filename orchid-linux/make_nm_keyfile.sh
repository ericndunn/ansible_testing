#!/bin/bash

usage() {
	echo "Usage: $0 CONNECTION_NAME"
	echo
	echo "Print to STDOUT a NetworkManager keyfile for the current network connection"
	echo "with name CONNECTION_NAME (e.g., \"Wired connection 1\")."
	echo
}

connection_name="$1"

if [[ $# -ne 1 ]]; then
	usage
	exit 1
fi

uuid=$( nmcli c \
	| grep "^$connection_name" \
	| sed "s/^$connection_name//" \
	| tr -s ' ' \
	| sed 's/^\s*//' \
	| cut -d ' ' -f 1 )

if [[ -z "$uuid" ]]; then
	echo "ERROR: Could not find entry for connection \"$connection_name\"."
	echo
	exit 1
fi

connection_params="$( nmcli c list uuid ${uuid} | tr -s ' ' )"

mac_address="$( echo "$connection_params" \
	| grep "^802-3-ethernet.mac-address:" \
	| cut -d ' ' -f 2 )"

echo "[802-3-ethernet]
auto-negotiate=true
mac-address=${mac_address}

[connection]
id=Wired connection 2
uuid=${uuid}
type=802-3-ethernet
timestamp=0

[ipv6]
method=ignore

[ipv4]
method=manual
dns=;
address1=192.168.2.101/24,0.0.0.0"
