#!/bin/bash

# A collection of commonly used functions by IPConfigure Orchid Fusion API scripts

show_message() {
    printf '=%.0s' {1..80} >&2 ; echo >&2
    fold -w 80 -s <<< "$1" >&2
    printf '=%.0s' {1..80} >&2 ; echo >&2
}

# Print an error message and exit with failure status.
die_with_error() {
    ERR="$1"
    if [[ -z $ERR ]]; then
        ERR="Something went wrong!"
    fi
    show_message "$ERR"

    rm -f ${errs}
    kill $$ 
    exit 1
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    die_with_error "ERROR: This script cannot be called directly.  It's designed to be sourced by other IPConfigure scripts."
fi

get_local_fusion_uri() {
    props_file="/etc/opt/fusion/fusion.properties"
    [[ -f ${props_file} ]] || die_with_error "Couldn't find Fusion properties file at ${props_file}.  Is Fusion even installed, bro?"

    protocol=$( grep '^listening.protocol' < ${props_file} | sed 's/\s\+//g' | cut -d '=' -f 2 ) 
    port=$( grep '^listening.port' < ${props_file} | sed 's/\s\+//g' | cut -d '=' -f 2 ) 

    echo "${protocol}://localhost:${port}"
}

# Generic query on a Fusion server.  Parameters:
#     $1: Fusion server URI
#     $2: Authorization token
#     $3: Fusion endpoint, e.g. fusion/orchids
#     $4: jq query to format/filter the HTTP response
#     $5: Text description of the query displayed in error messages
#     $6: HTTP verb.  Optional.  Defaults to GET.
#     $7: HTTP request body.  Optional.
generic_fusion_query() {
    fusion_uri="$1"
    token="$2"
    endpoint="$3"
    jq_query="$4"
    description="$5"
    verb="$6"
    data="$7"

    [[ $# -ge 5 ]] || die_with_error "Bad parameters to generic_fusion_query()"

    errs=$(mktemp)
    cmd="curl -ksv \"${fusion_uri}/${endpoint}\" -H \"Content-Type: application/json\""

    [[ -z $token ]] || cmd+=" -H \"Authorization: Bearer ${token}\""
    [[ -z $verb ]] || cmd+=" -X ${verb}"
    [[ -z $data ]] || cmd+=" -d \"$( sed 's/"/\\"/g' <<< ${data}) \""

    cmd+=" 2> ${errs}"

    [[ -z $fusion_query_debug ]] || ( echo "$cmd" 1>&2 ; rm -f $errs ; die_with_error "Terminating due to debug command" )

    response=$( eval $( echo $cmd ))
    [[ $? -eq 0 ]] || die_with_error "Failed to ${description}: $( cat ${errs} )"  

    result=$( jq -r "${jq_query}" <<< "$response" 2> ${errs} )
    ( [[ $? -eq 0 ]] && [[ $token != "null" ]] ) || die_with_error "Failed to parse response from ${description}: ${response}, jq errors: $( cat ${errs} )"

    echo $result
    rm -f ${errs}
}

get_auth_token() {
    fusion_uri="$1" 
    username="$2"
    password="$3"
    [[ $# -eq 3 ]] || die_with_error "Bad parameters to get_auth_token()"

    generic_fusion_query "$fusion_uri" "" "fusion/users/login" ".token" "log in to Fusion" \
        "POST" "{ \"username\": \"$username\", \"password\": \"${password}\" }"
}


# Get a list of all the Orchid IDs registered to a Fusion server
#     $1: Fusion server URI
#     $2: Authorization token
get_registered_orchid_ids() {
    fusion_uri="$1"
    token="$2"
    [[ $# -eq 2 ]] || die_with_error "Bad parameters to get_registered_orchid_ids()"

    generic_fusion_query "$fusion_uri" "$token" "fusion/orchids" ".[].id" "get list of Orchids"
}

# Get the CACHED status of an Orchid server
#     $1: Fusion server URI
#     $2: Authorization token
#     $3: Orchid server UUID
get_orchid_status() {
    fusion_uri="$1"
    token="$2"
    orchid_id="$3"
    [[ $# -eq 3 ]] || die_with_error "$# Bad parameters to get_orchid_status()"

    generic_fusion_query "$fusion_uri" "$token" "fusion/orchids/${orchid_id}" "." "get cached Orchid status" "GET"
}

# Get the REAL status of an Orchid server, directly from the Orchid server.
#     $1: Fusion server URI
#     $2: Authorization token
#     $3: Orchid server UUID
get_orchid_status_hardcore() {
    fusion_uri="$1"
    token="$2"
    orchid_id="$3"
    [[ $# -eq 3 ]] || die_with_error "Bad parameters to get_orchid_status_hardcore()"

    generic_fusion_query "$fusion_uri" "$token" "fusion/orchids/${orchid_id}" "." "get cached Orchid status" "PURGE"
}
