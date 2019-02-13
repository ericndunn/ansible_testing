#!/bin/bash

die_with_error() {
    printf '=%.0s' {1..80} ; echo
    fold -w 80 -s <<< "ERROR: $1"
    printf '=%.0s' {1..80}
    exit 1
}

usage() {
    echo "Usage: $0 <directory>"
    echo
    echo "Convert old-style VPN client records to new-style VPN client records. "
    echo
    exit 1
}

init() {
    if [[ $# -ne 1 ]]; then
        usage
    fi

    directory="$1"
    [[ -d "$directory" ]] || die_with_error "$directory is not a directory."

    cd "$directory"
    client_id=$(basename "$PWD")
    old_vpn_conf="${client_id}.conf"
    old_https_crt="${client_id}.crt"
    old_https_key="${client_id}.key"
    old_https_csr="${client_id}.csr"

    [[ -f "${old_vpn_conf}" ]] || die_with_error "Missing expected VPN configuration file ${old_vpn_conf}"
    [[ -f "${old_https_crt}" ]] || die_with_error "Missing expected HTTPS certificate file ${old_https_crt}"
    [[ -f "${old_https_key}" ]] || die_with_error "Missing expected HTTPS key file ${old_https_key}"
    [[ -f "${old_https_csr}" ]] || die_with_error "Missing expected HTTPS CSR file ${old_https_csr}"
}

extract_vpn_cert() {
    cat "${old_vpn_conf}" | awk '/<key>/,/<\/key>/' | sed "$ d" | sed "1 d" > ${client_id}-vpn.key
    cat "${old_vpn_conf}" | awk '/<cert>/,/<\/cert>/' | sed "$ d" | sed "1 d" > ${client_id}-vpn.crt
}

update_file_names() {
    mv "${old_vpn_conf}" "${client_id}-vpn.conf"
    mv "${old_https_crt}" "${client_id}-https.crt"
    mv "${old_https_key}" "${client_id}-https.key"
    mv "${old_https_csr}" "${client_id}-https.csr"
    ln -sf /usr/local/share/ca-certificates/fusion-cloud-ca.crt
}

init "$@"
extract_vpn_cert
update_file_names
