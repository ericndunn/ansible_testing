#!/bin/bash

download_server_key=\
"LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFb2dJQkFBS0NBUUVBcDVUankxWWIz
bnAxRlZTSGZGZk5DY2ZKYjIydjE0TmpwaEJsMlN5QU1aR1ZtYTQyCnJOT0ltb0U1N2t3NnFIR2s1
TzRhaVY2V21nODJuSU42c3hteitaeHpjMlhwa0ZCUGRlQ3JaZkZud255eVNWRk0KVVdibERSTkpx
ZzFHV3dKYzZ3WjVIWjdIK1hraXowTzJoL1dqOUoyV01QRFVnNVh3MEdoREhRdUlwQnQvVlRFZAo5
WFZPckFscFRKTlpqYTlRMmljYklZWHppK2RhNEtIUVV4SllZQmw4Q0pjNWk4Y2FjYVh2TDNwclZS
Q09FaFovCit5S0dWdlUwc2NyK1puaEIvOG83SGJQZXVLdk9kWkl3bjh3alU0SWZIRE1laDg0RTdt
VFFWOHZLRmxodGh3VE4KTGFhZ2VnQlNsV3dFUXpNSXcxUW9CNklwaXZYNi96YnkxRFpHQndJREFR
QUJBb0lCQUdnQmJnY3FvQTFKN3hTWAo2Nlp1VDZDOFQvWktHeElrUjFvdlh5YVVDZE81eVNFaUVH
amV1Qzg3K0pvKzBVRHRseXRGNDA1U1dDR3hRM0dMCjRFRDd1TWs0SWljQ254eWoyMDBMYlJUTjZG
bTZUbVJXZ29rYTFSbHlXUXVqUllFQ1RHekpEYTRtZDNJTGptRVkKWTFhcVMyRnIxR1QzY3MxZjU1
OVF0aVoybkExTXluYm1KUmhFVmhVNzRjWGducjZTVi8xdS9MZUp6aEtMdGFORwp4Q0FoN0dmZ2Nv
RVYvSnlqeTRDcEJMRjdHRmlzUHJKaS92ZWU0QVgvM3NEY0k3NlJiMC9hYTAwc0tieFgwTVZlCnNL
K0czTW9nNmhwbXNpN3hTV1J2WkZVME1yY1hZUDV5ZDVueFh6cnQ2MnlOME9Kakx4ZXVXQXN3Zk9y
VGlleEEKeFcrTnlLRUNnWUVBenlMd2d4MzlidFdrVW03WmoxU2NENXMzZ1Jpd1JzTmczSkZJTE1I
Y1AwMytmb2U0OFVUawpGVmRWZENQNldNUWNIdjE2Nm1mTUZJaEp4R0JXVFNyTmlpYXFBZmtHLyt1
WUNyOWxsSSsvYUluSmFHcjVqdVY2CjFQSVNFWGpoUzlJL2hjbjFxaFdmTVN6cDZGTm9zWHhJVWlU
b1U0RjV0clNCRHNQSnF3K3UvdDhDZ1lFQXp4MDIKMHZmdm51eW1od2FZbmU1bG9HTDAweUZBZkZT
Tjhid1lMRTNLVGUyMVhhUGNDeWlpc2VUWnJoK2F2MUx1T0M1RAppVGtTSlJkWEc1Sm5XNkdGUzR2
Z0t6TE5ZUTZ6WW5NNC91bi8xbS8xaVhGdjNJK2NMcnFGZUUvV3NXY0thb0N0CnF6RU1NcjBtZk5K
d1ROODhlWm1RMmxlMGtGS29tcDBSR2VVMkpka0NnWUJqSFFYV3gzL2dDK3cvNFhqS3c2S1YKT1NF
NjdaUlRsK04rUnlvdytHWXFDR2p4SklKVE9ES25INDN0TDlYM3FZY0hNU1VpaXA0MWFPMWJRUG1x
blFPUwp5bU5vNUQ3OE1FQWxUR1lQeXlTOG9jbTA1Qk1iMUNTTlJuTnMxdGwvRFZDRjlSaE8xVi9D
Q1FxM3QwbU9PN2pqClRYTzVtV2VqREFZQkNhQXk4U004SXdLQmdEQmNpdnV5SjBLOTBaaS80bzBt
S0piTjVJc1VQYUdLZ09hTVhEeWsKSVhRVzZIMm9FRzZPbTRiY2dEUFhiMlB6Y21xdDZ0azArVmF0
MzRveG9tN1VCWE1CZzJPeTVpQWV0YVpzYjBlZQp6ajE5UVNGSjJxdnU0TEpNblhQZGVLMU4rVEdy
UUdJei9yd3VUTGxpemhRMUlFTG9wOWxFRjRhSHRwVDd6ZzEwCjV6THBBb0dBZmlINkw3dFpnZ28y
d0drNytBSndqcTh0Z1pLWDNEdm1EajJENU9pSlNzZ2ZpazU1OXo2WDdLbjQKaTdheS80SkFNaDM0
TDBXcjNHUWZrSExkOWR1OHZveDJ3TkxxTUVWLy94WGpyOWRvbXY4MEwxdlpKQkNCL1puTQpBVzha
bXZrRncyU2IvYjdVZ1FvckRoOGJ4U1k4WHoyYThvSlBUK1hYTWNheGF3TjNRTW89Ci0tLS0tRU5E
IFJTQSBQUklWQVRFIEtFWS0tLS0tCg=="

die_with_error() 
{
    printf '=%.0s' {1..80} ; echo
    fold -w 80 -s <<< "ERROR: $1"
    printf '=%.0s' {1..80}
    exit 1
}

verify_rootness()
{
    if [[ $EUID -ne 0 ]]; then
        die_with_error "This script must be run as root."
    fi
}

# GET. ON. MY. LEVEL.
show_usage()
{
    echo
    echo "Usage: ${0} <CUSTOMER_ID> <SERIAL_NUMBER> [UNDO]"
    echo
    echo "  <CUSTOMER_ID> - A unique customer identifier.  This server must have been "
    echo "                  previously configured using the setup_hosted_server.sh script"
    echo "                  using the same customer identifier."
    echo
    echo "<SERIAL_NUMBER> - A unique identifier for the newly added server.  Typically "
    echo "                  this is a SteelFin server serial number, but may also be an"
    echo "                  order number with a serialized extension."
    echo
    echo "           UNDO - If specified, remove all records for the given serial number"
    echo "                  from this server."
    echo
}

set_config() 
{
    if [[ $# -lt 2 ]] || [[ $# -gt 3 ]] || ( [[ $# -eq 3 ]] && [[ "$3" != "UNDO" ]] ); then
        show_usage
        exit 1
    fi
    
    customer_id="$1"
    serial_number="$2"
    bundle_dir="/home/fusion/client_configs/${customer_id}/${serial_number}"

    if [[ "$3" == "UNDO" ]]; then
        undo_config
        exit 0
    fi
}

undo_config()
{
    rm -rf ${bundle_dir}
    sed -i "/${client_ip}[[:space:]]*${customer_id}-${serial_number}.*/d" /etc/hosts
    sed -i "/${customer_id}-${serial_number},${client_ip}/d" /etc/openvpn/${customer_id}-ipp.txt
    sed -i "/CN=${customer_id}-${serial_number}\\//d" /etc/openvpn/${customer_id}-easyrsa/keys/index.txt
    rm -f /etc/openvpn/${customer_id}-easyrsa/keys/${customer_id}-${serial_number}.*
    rm -f /etc/openvpn/${customer_id}-ccd/${customer_id}-${serial_number}
}

verify_server_configured() 
{
    # Verify Fusion is installed.
    fusion_binary="/opt/fusion/bin/fusion"
    if [[ ! -f "$fusion_binary" ]]; then
        die_with_error "Fusion is not installed at ${fusion_binary}."
    fi

    # Verify VPN has been configured.
    easyrsa_dir="/etc/openvpn/${customer_id}-easyrsa"
    if [[ ! -d "$easyrsa_dir" ]]; then
        die_with_error "Easy RSA directory is missing: ${easyrsa_dir}.  Have you run setup_new_hosted_kvm.sh?"
    fi
    
    # Verify this serial number hasn't already been set up!
    if cat /etc/openvpn/${customer_id}-easyrsa/keys/index.txt | grep "CN=${customer_id}-${serial_number}/" &> /dev/null ; then
        die_with_error "${customer_id}-${serial_number} has already been enrolled!  Remove this enrollment by running \"add_client.sh ${customer_id} ${serial_number} UNDO\", or pick a different serial number."
    fi

    vpn_ip="${customer_id}.ipconfigure.com"
    vpn_port=$( cat /etc/openvpn/offsets.txt 2> /dev/null | grep ${customer_id} | cut -d ' ' -f 3 )
}

# Attempt to guess what this client's VPN address should be.  Prompt
# user for verification/override.
get_my_vpn_ip_address()
{
    # Show the IP addresses in use and prompt for the IP you want for
    # this new client.
    echo 
    echo "CURRENT VPN IP ADDRESSES:"
    echo "========================="
    cat /etc/openvpn/${customer_id}-ipp.txt
    echo

    # Get the IP address of the most recently added client (we'll want to increment this by 1)
    previous_ip=$( sudo cat /etc/openvpn/${customer_id}-ipp.txt | tail -n 1 | cut -d ',' -f 2 )
    ip_increment=1

    # If the file is empty, let's pre-populate on our own using the server config file.
    if [[ "$previous_ip" == "" ]]; then
        previous_ip=$( sudo cat /etc/openvpn/${customer_id}-fusion.conf | grep server | cut -d ' ' -f 2 )

        # The server is using the .1 IP, so here we'll need to increment by 2.
        ip_increment=2
    fi

    client_ip=$( printf "%s.%s" \
         $( echo $previous_ip | grep -o '[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*' ) \
             $(( $( echo $previous_ip | grep -o [0-9][0-9]*$ ) + $ip_increment )) )

    # Prompt for client IP addresses (prefill with guess from above):
    echo
    read -e -p "Specify IP address: " -i "$client_ip" client_ip

    if [[ $( echo $client_ip | cut -d '.' -f 4 ) -ge 255 ]]; then
        die_with_error "IP Address $client_ip is too high!  You've maxed out this subnet; increment the previous octet and try again."
    fi

    # Verify the specified IP isn't already in use
    if sudo cat /etc/openvpn/${customer_id}-ipp.txt | grep ${client_ip} > /dev/null; then
        echo "ERROR: IP address already in use."
        echo
        return 1
    fi

    # Tell the user the IP address and hostname we're using, give an 
    # opportunity to bail out.
    echo
    echo "============================================="
    echo "USING IP ADDRESS: $client_ip"
    echo "   SERIAL NUMBER: $serial_number"
    echo "     VPN ADDRESS: ${vpn_ip}"
    echo "        VPN PORT: ${vpn_port}"
    echo
    echo "(Press enter to continue or Ctrl-C to quit)"
    echo "============================================="
    read
}

generate_vpn_keys() 
{
    pushd .
    cd /etc/openvpn/${customer_id}-easyrsa
    source ./vars
    ./pkitool ${customer_id}-${serial_number}
    popd

    mkdir -p "${bundle_dir}"
    cp -v /etc/openvpn/${customer_id}-easyrsa/keys/${customer_id}-${serial_number}.crt ${bundle_dir}/${customer_id}-${serial_number}-vpn.crt
    cp -v /etc/openvpn/${customer_id}-easyrsa/keys/${customer_id}-${serial_number}.csr ${bundle_dir}/${customer_id}-${serial_number}-vpn.csr
    cp -v /etc/openvpn/${customer_id}-easyrsa/keys/${customer_id}-${serial_number}.key ${bundle_dir}/${customer_id}-${serial_number}-vpn.key
    true
}

generate_https_keys() 
{
    pushd . ; cd ${bundle_dir}

    # Extended attributes (alt_names) for generating an HTTPS key must be specified in a separate file.
    cat > v3.ext << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
DNS.2 = ${customer_id}-${serial_number}
EOF

    # We also need the Fusion Cloud CA key.
    cat > fusion-cloud-ca.key << EOF
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAqxphkCx0ckhpPBPNcvmbZ60hCB1Bvgjr6CoKuifGeDRHRyjb
PHOXvRhX5qY/0jFY9uGMqGgPm68JwO4QHF8MMvcfbK0oGr8RkXs8QCACvBtVdvsH
kfHcoBFrLvLENlJ18o8mPxZApmxvDkVUViJWELaZFOvOLI9lKM8m8A9Qyk6wgLOg
SUcVz9BCO9UEyEDdNmcFplwEFD9oZp5PgKqCR651RWrNUcjLMFfdBwq9FCKniF25
UOGK5d/eBf7WOqyVXFfyDyanjaqjRdrqNBCAip2kFKbtNT91SoB1GWiSJ6a4f00E
CsiG7PkisfHF/rzIJXessru3KQ8w3DqHJAbPbQIDAQABAoIBADR8u0EG4hHMtLuB
N5z1hP6g1Wkv0GMDSZrGitPgL7ngD518owRAUWPoe859YUaRbMEPH57pjSAs6ckN
PlP1tEBOHo2v8IWD51fBfhINv8kEeYsuJnxWvV88+KxGPHqNgTEPSKRBp0NmMAso
qV5i2hP2b69DRtPUiSujoEYz7IyiZje5XXWqxg3Va7AD+by+kXJ87Y3qwfXXjFnM
YmyVISStp+oTAlHTC2/LEBkr3vFEl53e+yg3+gCilx5Y+faNrxr2xkBX4fWYO2Gs
AanI6A2IshDB/yaOXUvDRRK7jAEIXefb2ZNU4c61mlFxU1YGwqeCkcZUymTqt7FS
nOnx+OECgYEA4LjEUmP0f2eGMqEvjT+TisyHqlK/Fp8pFNW7YeJrxVwzV8WLUf0c
u1v647HLJ5esUwBZ7biwRg68ZCTuGc/6cqmvKWT2XcJHmZ+ZU4ZVYgye5BKh3s20
wiVOFo9+/b64j9fLPLy2EJBcjancauDZbChAXNEd1rkUlLZ1HR2bxPMCgYEAwusV
2NvylA5/Udo3uvZ9Qx6cbWxdDnSpF/RngnA0lHRO2FVBBH0L2tIkIbi5n4GCv0KO
oaJW7sCRF3Xlif86KYPTc7daiPx13wsdlf5hJO4K+sS+dhnywxyh6BbKhn9JPo22
HyCoWZavakIaY3p2JU6LPJ3KFESEYbl0JOYjsh8CgYBl0ZGyOvPG3iMhwYKIHyw8
kVtOwtst5sN4WzbhrPNjotjohesQJPzlr1FH5YDE2aYMnXYhjbLgq0CUp17ydxdk
6JkiykoORT6nznZsL8tz93/umrqY9t9VsA1nj3Dci5OYKRA+3sonSyGEVlg2XNZm
eP5gj6dTaNx4XQtHO+keHQKBgQC7A1Dny0f4E9zGjOdRo7NVVaZiOkkiWH3wdNdn
R/66vMj1OP7zroJURbDTBehbCKiIlvRAUoCz++B5sO01tMJ6GHglmzLrIcZ55LFT
O0i7ZQT1yxSuPYE1AGC7TDquRqvgr5igTvYXVsMg4SFudo2qh6yB0SaUwZR+KrAr
wv9WowKBgEt6nKOyNt/gwz5RclWFlSDZKD7+htQ51nluQgMfw519qNEIjDUvlGpo
Yazqpj7PCji1aNDLzxOJ38r6k/LorP9yP8GyWRfLEiuMUJD9Fy9GZZItmn4TO/Vy
rIcXHjqxsxkct4LxBT6wa6R0xz7MYwmMEGbDHtNH0xXrQrgwYw4L
-----END RSA PRIVATE KEY-----
EOF

    # Generate the HTTPS key/cert pair.
    openssl genrsa -out ${customer_id}-${serial_number}-https.key 2048
    openssl req -new \
        -key ${customer_id}-${serial_number}-https.key \
        -out ${customer_id}-${serial_number}-https.csr \
        -subj "/C=US/ST=Virginia/L=Norfolk/O=IPConfigure, Inc./CN=${customer_id}-${serial_number}"
    openssl x509 -req \
        -in ${customer_id}-${serial_number}-https.csr \
        -CA /usr/local/share/ca-certificates/fusion-cloud-ca.crt \
        -CAkey fusion-cloud-ca.key \
        -CAcreateserial \
        -out ${customer_id}-${serial_number}-https.crt \
        -days 3650 -sha256 -extfile v3.ext

    ln -s /usr/local/share/ca-certificates/fusion-cloud-ca.crt
    rm -f fusion-cloud-ca.key
    popd
}

configure_hostname_and_ip() {
    # Add the the new client's hostname to the servers hosts file.  Remove any
    # existing entries to prevent duplicates.
    sed -i "/${client_ip}[[:space:]]*${customer_id}-${serial_number}.*/d" /etc/hosts
    echo ${client_ip} ${customer_id}-${serial_number} >> /etc/hosts

    # Add the the new client's hostname to the servers ipp.txt file.  Remove any
    # existing entries to prevent duplicates.
    sed -i "/${customer_id}-${serial_number},${client_ip}/d" /etc/openvpn/${customer_id}-ipp.txt
    echo ${customer_id}-${serial_number},${client_ip} >> /etc/openvpn/${customer_id}-ipp.txt

    echo "ifconfig-push ${client_ip} 255.255.0.0" > /etc/openvpn/${customer_id}-ccd/${customer_id}-${serial_number}
}

# Copy the deployment script to download.ipconfigure.com
copy_deployment_script() {
    key=$( mktemp )
    base64 -id <<< "$download_server_key" > $key
    download_dir="/home/orchid/misc_installs/${customer_id}/${serial_number}"
    ssh -i $key orchid@download.ipconfigure.com mkdir -p ${download_dir}
    scp -i $key ${bundle_dir}/deploy-ubuntu-${customer_id}-${serial_number}.sh \
        orchid@download.ipconfigure.com:${download_dir}/
    rm -f $key
}

set_config "$@"
verify_rootness
verify_server_configured
get_my_vpn_ip_address
generate_vpn_keys
generate_https_keys
configure_hostname_and_ip
$(dirname "$0")/tools/deployment/generate_deployment_script.sh \
    "${customer_id}" "${serial_number}" || die_with_error "ERROR: Failed to generate deployment script"
# copy_deployment_script

echo "\

COMPLETE! The following generated files will now need to be deployed to the 
client Orchid Core server:

    - OpenVPN Configuration: ${bundle_dir}/${customer_id}-${serial_number}-vpn.conf
    - Orchid TLS Key:        ${bundle_dir}/${customer_id}-${serial_number}-https.key
    - Orchid TLS Certicate:  ${bundle_dir}/${customer_id}-${serial_number}-https.crt
    - Fusion Cloud CA:    :  ${bundle_dir}/fusion-cloud-ca.crt

You can automatically deploy these files and perform other useful configuration
steps by running one of the following self-contained generated scripts on the 
client Orchid Core server (the files above are embedded in the scripts):

    - ${bundle_dir}/deploy-linux-${customer_id}-${serial_number}.sh
    - ${bundle_dir}/deploy-windows10-${customer_id}-${serial_number}.sh

You can regenerate the OpenVPN configuration and deployment script using the keys
and certificates saved in /home/fusion/client_configs by running:

    $(dirname "$0")/tools/deployment/generate_deployment_script.sh ${customer_id} ${serial_number}

If you've made a horrible mistake, you can remove all records of the client 
configuration you've just generated by running:

    $0 $@ UNDO"
