#!/bin/bash

source "${STEELFIN_SCRIPT_ROOT}/vpns/tools/monitoring/fusion_api/fusion_common.sh"

usage() {
    echo "Usage: ${0} <username> <password> [<action>] [<uri>]"
    echo
    echo "Retrieve all the Orchid Core VMS servers registered to an Orchid Fusion VMS"
    echo "server."
    echo
    echo "   username: Orchid Fusion VMS server username"
    echo "   password: Orchid Fusion VMS server password"
    echo "     action: Specify an action (see below).  Default = list_all"
    echo "        uri: Orchid Fusion VMS server URI.  Optional: if not specified, the"
    echo "              local Orchid Fusion VMS URI is inferred from"
    echo "             /etc/opt/fusion/fusion.properties"
    echo
    echo "  List of actions:"
    echo
    echo "           list_all: Show all Orchids"
    echo "          count_all: Show number of Orchids"
    echo "        list_online: Show online Orchids"
    echo "       count_online: Show number of online Orchids"
    echo "       list_offline: Show offline Orchids"
    echo "      count_offline: Show number of offline Orchids"
    echo
    echo 
    exit 1
}

verify_params() {
    if [[ $# -ne 2 ]] && [[ $# -ne 3 ]] &&  [[ $# -ne 4 ]] ; then
        usage "${@}"
    fi

    username="$1"
    password="$2"
    action="$3"
    uri="$4"

    [[ ! -z "$action" ]] || action="list_all"
    [[ ! -z "$uri" ]] || uri=$( get_local_fusion_uri )
    [[ ${action_query["$action"]+abc} ]] || usage
}

ms_ptime_to_format_filter() {
    field_name="$1"
    [[ ! -z $field_name ]] || die_with_error "Bad parameters to ms_ptime_to_format_filter"
    echo " .${field_name} = (.${field_name} / 1000 | floor | strftime(\"%Y-%m-%d %H:%M:%S UTC\"))"
}

# Fusion returns some fields that are noise to us.  Show only these, and 
# convert ptimes to readable dates:
result_filter="{ 
    id, name, uri, isAvailable, version, 
    failureReason, camerasOnline, camerasAvailable, 
    lastAvailable, lastChecked }
    | $( ms_ptime_to_format_filter 'lastChecked')
    | $( ms_ptime_to_format_filter 'lastAvailable' )" 

declare -A action_query
action_query["list_all"]="map( $result_filter )"
action_query["count_all"]="${action_query['list_all']} | length"
action_query["list_online"]="map(select(.isAvailable == true) | $result_filter)"
action_query["count_online"]="${action_query['list_online']} | length"
action_query["list_offline"]="map(select(.isAvailable == false) | $result_filter)"
action_query["count_offline"]="${action_query['list_offline']} | length"



verify_params "${@}"
token=$(get_auth_token "$uri" "$username" "$password")

get_orchid_status "$uri" "$token" "" | jq "${action_query["$action"]}"

# Additional filters that can applied to list results of this script:
#
# Show URIs of all Orchids whose version is not 2.0.1:
#    | jq -r 'map(select(.version != "2.0.1") | { uri } | flatten | .[0] ) | .[]'
#
# Show URIs of all offline Orchids
#    | jq -r "map({uri} | flatten | .[0]) | .[]  "
#
# Show just the ID and URIs of offline Orchids as a flat text file.  This is useful
# for processing in a bash script (e.g., to re-register Orchids).
#    |  jq -r "map({id, uri} | flatten) | .[] | .[]" | paste -d ' ' - -
#
