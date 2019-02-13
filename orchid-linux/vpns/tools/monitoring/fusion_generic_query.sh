#!/bin/bash

source "${STEELFIN_SCRIPT_ROOT}/vpns/tools/monitoring/fusion_api/fusion_common.sh"

usage() {
    echo "Usage: ${0} <username> <password> <endpoint> [<verb>] [<data>] [<base-uri>]"
    echo "                                                                               " 
    echo "Perform a generic query on an Orchid Fusion server using a customizable cURL "
    echo "query, while automatically handling the rigmarole of genereting and passing"
    echo "the Fusion authorization token."
    echo
    echo "       username: Orchid Fusion VMS server username"
    echo "       password: Orchid Fusion VMS server password"
    echo "       endpoint: Orchid Fusion endpoint, without protocol, hostname, or port."
    echo "                 For example: \"/fusion/orchids/\"."
    echo "           verb: HTTP verb.  Optional, default = GET."
    echo "           data: Optional POST data."
    echo "       base-uri: Orchid Fusion VMS server URI.  Optional: if not specified,"
    echo "                 the local Orchid Fusion VMS URI is inferred from"
    echo "                 /etc/opt/fusion/fusion.properties"
    echo 
    exit 1
}

verify_params() {
    if [[ $# -lt 3 ]] || [[ $# -gt 6 ]]; then
        usage "${@}"
    fi

    username="$1"
    password="$2"
    endpoint="$3"
    verb="$4"
    data="$5"
    uri="$6"

    # Remove leading slashes from endpoint.
    endpoint=$( sed 's/^\/\+//g' <<< "$endpoint" )

    [[ ! -z "$uri" ]] || uri=$( get_local_fusion_uri )
}

verify_params "${@}"
token=$(get_auth_token "$uri" "$username" "$password")

generic_fusion_query "$uri" "$token" "$endpoint" "." "Generic query" "$verb" "$data"

###############################################################################
# Tips & Tricks
###############################################################################
<< '###'

You'll often need to use jq to build the $data member:

RECOVERING ORCHIDS:
===================
 Example: Convert a string of the form "<id>|<uri>|<name>|<user>|<password>" to a 
          JSON object suitable for PATCHING a /fusion/orchids/{id} endpoint with
          to recover an Orchid:

    jq --raw-input --slurp \
        'split("\n") | .[0] | split("|") |
        { 
            "id": .[0], 
            "uri": .[1], 
            "name": .[2], 
            "username": .[3], 
            "password": .[4]
        }' \
        <<< "$input_string"

###
