#!/bin/bash

if [[ ! -f /usr/bin/expect ]]; then
    sudo apt install expect
fi

vpn_api="${STEELFIN_SCRIPT_ROOT}/vpns/tools/monitoring/vpn_api"

vpn_port=$(cat /etc/openvpn/*conf | grep ^management | tr -s ' ' | cut -d ' ' -f 3)
${vpn_api}/active_vpn_clients.expect $vpn_port | awk '/ROUTING TABLE/,/GLOBAL STATS/' | grep -E '^[0-9]+' | cut -d ',' -f 1,2,3 | sed 's/:[0-9][0-9]*$//'

