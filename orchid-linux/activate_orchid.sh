#!/bin/bash

usage() {
    echo "Usage: $0 ACTIVATION_CODE LOCATION [USER [PASS [CONNECTION_STRING]]]"
    echo
    echo "     Activate an Orchid Core server running on CONNECTION_STRIING with the"
    echo "     given ACTIVATION_CODE and an optional USER and PASS (defaults are orchid"
    echo "     / 0rc#1d.  The default CONNECTION_STRING is \"http://localhost\"."
    echo "     LOCATION is the \"Location Description\" field used when activating the"
    echo "     Orchid license."
    echo
    exit 1
}

require_dep() {
    if ! which "$1" &> /dev/null; then
        echo "ERROR: Could not find required dependency $1."
        exit 2
    fi 
}

# Verify we have the right utilities available.
require_dep jq
require_dep curl

# Parameters defaults.
activation_code=""
location=""
user="admin"
pass="0rc#1d"
connection="http://localhost"

# Override defaults with command line parameters.
[[ -z "$1" ]] || activation_code="$1"
[[ -z "$2" ]] || location="$2"
[[ -z "$3" ]] || user="$3"
[[ -z "$4" ]] || pass="$4"
[[ -z "$5" ]] || connection="$5"

# Verify all parameters are specified.
if [[ -z "$activation_code" || -z "$user" || \
      -z "$pass" || -z "$connection" || -z "$location" ]]; then
    usage
fi

# Get mid from Orchid.
mid=$( curl -m 20 -s -k -u "$user":"$pass" "${connection}/service/discoverable/orchids" \
     | jq -r ".orchids[0].mid" )

# Verify we got the mid.
if [[ -z "$mid" || $mid == "null" ]]; then
    echo "ERROR: Failed to retrieve Machine ID.  Are you credentials and connection"
    echo "string correct?"
    echo
    exit 3
fi

# Now POST!
activation_url="https://www.orchidsecurity.com/activation/"
license="$( curl -m 20 -s -k -X POST \
    -F "activation_code=$activation_code" \
    -F "machine_id=$mid" \
    -F "location_description=$location" \
    -F "headless=1" \
    "$activation_url" | jq -r .license )"

if [[ -z "$license" || $license == "null" ]]; then
    echo "ERROR: Failed to activate license.  Try it manually at"
    echo "https://orchidsecurity.com/activation for more info."
    echo
    exit 4
fi

version=$( curl -m 20 -s -k -u "$user":"$pass" "${connection}/service/version" | jq -r .version )
if [[ ${version:0:1} == "1" ]]; then
    license_body="$license"
else
    # Make POST body for /service/license-session
    license_body="$( jq -n --arg license "$license" '{ "license": $license }' )"
fi

# Activate Orchid license
curl -m 20 -k -X POST \
     --data "$license_body" \
     -u "$user":"$pass" "${connection}/service/license-session"
