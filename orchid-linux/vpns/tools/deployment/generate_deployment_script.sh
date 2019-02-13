#!/bin/bash

die_with_error() {
    ERR="$1"
    if [[ -z $ERR ]]; then
        ERR="Unknown failure in deployment script generator."
    fi

    printf '=%.0s' {1..80} ; echo
    fold -w 80 -s <<< "$ERR"
    printf '=%.0s' {1..80}
    exit 1
}

verify_rootness()
{
    if [[ $EUID -ne 0 ]]; then
        die_with_error "This script must be run as root."
    fi
}

show_usage() {
    echo 
    echo "Usage: ${0} [<CUSTOMER_ID> [<SERIAL_NUMBER>] ]"
    echo
    echo "Generate a client VPN deployment script from a client_config directory"
    echo "containing OpenVPN and HTTPS keys. This deployment script is then run on the VPN"
    echo "client."
    echo
    echo "This script is typically called by add_client.sh, but it may also be invoked "
    echo "directly using existing client information.  Because the client deployment"
    echo "scripts are by design idempotent, they may be regenerated and re-run on existing"
    echo "VPN clients to update client configuration or functionality."
    echo
    echo "    <CUSTOMER_ID> - Previously used customer ID, whose records exist in the "
    echo "                    directory /home/fusion/client_configs/<CUSTOMER_ID>"
    echo 
    echo "  <SERIAL_NUMBER> - Previously used VPN client serial number, whose keys and"
    echo "                    certificates exist in the directory"
    echo "                    /home/fusion/client_configs/<CUSTOMER_ID>/<SERIAL_NUMBER>"
    echo
    echo "If SERIAL_NUMBER is not specified, regenerate all existing records for"
    echo "CUSTOMER_ID.  If CUSTOMER_ID is not specified, try to infer it."
    echo                         
}

verify_arguments() {
    if [[ $# -gt 2 ]] || [[ "$1" == "--help" ]]; then
        show_usage "$@"
        exit 1
    fi

    customer_id="$1"
    serial_number="$2"
    serial_number_list=( $serial_number )
    
    # No customer specified, let's infer.
    if [[ -z $customer_id ]]; then
        client_config=$( /bin/ls -d /home/fusion/client_configs/*/ 2> /dev/null )

        # If the result is empty or contains more than one directory, we cannot infer.
        if [[ -z $client_config ]] || [[ $( wc -l <<< "$client_config" ) -ne 1 ]]; then
            printf "ERROR: Unable to infer CUSTOMER_ID.  You must specify it manually.\n"
            show_usage
            exit 1
        fi
        customer_id=$( basename "$client_config" )
    fi

    [[ -d "/home/fusion/client_configs/${customer_id}/" ]] || die_with_error "Invalid Customer ID; could not find directory /home/fusion/client_configs/${customer_id}."

    # If no serial_number was specified, build our own list.
    if [[ -z $serial_number ]]; then
        serial_number_list=( $(/bin/ls -d /home/fusion/client_configs/${customer_id}/*/ 2> /dev/null | xargs -n 1 basename 2> /dev/null) )
    fi

    unset serial_number

    [[ ${#serial_number_list[@]} -ne 0 ]] || die_with_error "Serial number list is empty!"
}

verify_files_exist() {

    bundle_dir="/home/fusion/client_configs/${customer_id}/${serial_number}"
    if [[ ! -d "$bundle_dir" ]]; then
        die_with_error "ERROR: Could not find client configuration directory \"${bundle_dir}\"."
    fi

    required_files=( 
        "${bundle_dir}/${customer_id}-${serial_number}-vpn.key"
        "${bundle_dir}/${customer_id}-${serial_number}-vpn.crt"
        "${bundle_dir}/${customer_id}-${serial_number}-https.key"
        "${bundle_dir}/${customer_id}-${serial_number}-https.crt"
        "/etc/openvpn/${customer_id}-easyrsa/keys/ca.crt"
        "/etc/openvpn/${customer_id}-easyrsa/keys/ta.key"
        "/etc/openvpn/${customer_id}-ipp.txt"
        "/etc/openvpn/offsets.txt"
    )

    for required_file in "${required_files[@]}"; do
        if [[ ! -f "$required_file" ]]; then
            die_with_error "ERROR: Could not find required configuration file ${required_file}."
        fi
    done
}

get_hostname_ip_port() {
    trap die_with_error ERR
    orchid_hostname="${customer_id}-${serial_number}"
    client_ip=$( cat /etc/openvpn/${customer_id}-ipp.txt | grep "^${customer_id}-${serial_number}," | cut -d "," -f 2 )
    vpn_port=$( cat /etc/openvpn/offsets.txt | grep -E "^[0-9]+ ${customer_id} [0-9]+.*" | cut -d ' ' -f 3 )
}

generate_vpn_config() {
    trap die_with_error ERR

    cat << EOF > ${bundle_dir}/${customer_id}-${serial_number}-vpn.conf
client
dev tun
proto udp
remote ${customer_id}.ipconfigure.com ${vpn_port}
resolv-retry infinite
nobind
user nobody
group nogroup
persist-key
persist-tun
remote-cert-tls server
tls-auth ta.key 1
verb 3
cipher AES-128-CBC
auth SHA256
key-direction 1
<ca>
$( cat /etc/openvpn/${customer_id}-ca.crt )
</ca>
<cert>
$( cat ${bundle_dir}/${customer_id}-${serial_number}-vpn.crt )
</cert>
<key>
$( cat ${bundle_dir}/${customer_id}-${serial_number}-vpn.key )
</key>
<tls-auth>
$( cat /etc/openvpn/${customer_id}-ta.key )
</tls-auth>
EOF
}

generate_deployment_script() {
    trap die_with_error ERR

    template_file="$1"
    script_identifier="$2"
    template_md5=$( md5sum "${template_file}" | tr -s ' ' | cut -d ' ' -f 1 )

    pushd . &> /dev/null 
    cd "$( dirname "$template_file" )"
    git_hash=$( git rev-parse HEAD )
    popd &> /dev/null

    deployment_script="${bundle_dir}/deploy-linux-${customer_id}-${serial_number}${script_identifier}.sh"
    cp "${template_file}" ${deployment_script}

    sed -i "s/@ORCHID_HOSTNAME@/${customer_id}-${serial_number}/" ${deployment_script}
    sed -i "s/@CLIENT_IP@/${client_ip}/" ${deployment_script}
    sed -i "s/@TEMPLATE_MD5@/${template_md5}/" ${deployment_script}
    sed -i "s/@GIT_HASH@/${git_hash}/" ${deployment_script}
    sed -i "s/@GEN_DATE@/$(date)/" ${deployment_script}

    # sed silently ignores read/write errors in r,R,w,W commands (like missing files).
    # So it's up to us to make sure those files exist.
    required_files=(
        "/home/fusion/.ssh/id_rsa.pub"
        "${bundle_dir}/${customer_id}-${serial_number}-vpn.conf"
        "${bundle_dir}/${customer_id}-${serial_number}-https.key"
        "${bundle_dir}/${customer_id}-${serial_number}-https.crt"
        "/usr/local/share/ca-certificates/fusion-cloud-ca.crt"
    )

    for required_file in "${required_files[@]}"; do
        if [[ ! -f "$required_file" ]]; then
            die_with_error "ERROR: Missing required file \"${required_file}\"."
        fi
    done

    sed -i "/@FUSION_SERVER_PUBLIC_KEY@/r /home/fusion/.ssh/id_rsa.pub" ${deployment_script}
    sed -i "/@FUSION_SERVER_PUBLIC_KEY@/d" ${deployment_script}

    sed -i "/@OPENVPN_CONFIG_FILE@/r ${bundle_dir}/${customer_id}-${serial_number}-vpn.conf" ${deployment_script}
    sed -i "/@OPENVPN_CONFIG_FILE@/d" ${deployment_script}

    sed -i "/@FUSION_CLOUD_KEY@/r ${bundle_dir}/${customer_id}-${serial_number}-https.key" ${deployment_script}
    sed -i "/@FUSION_CLOUD_KEY@/d" ${deployment_script}

    sed -i "/@FUSION_CLOUD_CERT@/r ${bundle_dir}/${customer_id}-${serial_number}-https.crt" ${deployment_script}
    sed -i "/@FUSION_CLOUD_CERT@/d" ${deployment_script}

    sed -i "/@FUSION_CLOUD_CA@/r /usr/local/share/ca-certificates/fusion-cloud-ca.crt" ${deployment_script}
    sed -i "/@FUSION_CLOUD_CA@/d" ${deployment_script}
}

script_root=$(dirname "$0")

verify_rootness
verify_arguments "$@"

for serial_number in ${serial_number_list[@]}; do
    verify_files_exist
    get_hostname_ip_port
    generate_vpn_config
    generate_deployment_script "${script_root}/templates/configure_linux_client.sh.template" ""
    generate_deployment_script "${script_root}/templates/configure_linux_client_minimal.sh.template" "_minimal"
    echo "Successfully generated deployment for ${customer_id}-${serial_number}"
done

