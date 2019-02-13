#!/bin/bash

pushd . &> /dev/null
cd $( dirname "$0" )
script_dir="$( pwd -P )"
popd . &> /dev/null

usage () {
    echo \
"Usage: $0 CUSTOMER_ID OFFSET

This script will generate a configuration file and Easy RSA environment for a
VPN server used to host a new Fusion cloud customer.  

   CUSTOMER_ID: A unique text descriptor, e.g.: dennys

        OFFSET: A numeric offset used map this new customer to a unique set of
                ports.  Each customer should have an integer offset starting at
                0.  Don't get this wrong, or ports will conflict and things 
                will break.

After a successful execution, the following configuration files are created:

    OpenVPN configuration:
        /etc/openvpn/{CUSTOMER_ID}-fusion.conf

    OpenVPN server certificate and key, and misc:
        /etc/openvpn/{CUSTOMER_ID}-fusion.key
        /etc/openvpn/{CUSTOMER_ID}-fusion.crt
        /etc/openvpn/{CUSTOMER_ID}-ta.key
        /etc/openvpn/{CUSTOMER_ID}-dh2048.pem

    OpenVPN CA certificate and key:
        /etc/openvpn/{CUSTOMER_ID}-ca.crt
        /etc/openvpn/{CUSTOMER_ID}-ca.key

    OpenVPN IP persistence:
        /etc/openvpn/{CUSTOMER_ID}-ipp.txt

    OpenVPN log:
        /etc/openvpn/{CUSTOMER_ID}-openvpn-status.log

    Easy RSA environment:
        /etc/openvpn/{CUSTOMER_ID}-easyrsa/

"
}

die_with_error() {
    printf '=%.0s' {1..80} ; echo
    fold -w 80 -s <<< "$1"
    printf '=%.0s' {1..80}

    exit 1
}

verify_rootness() {
    if [[ "$EUID" -ne 0 ]]; then
        die_with_error "ERROR: You must run this script as root."
    fi
}

verify_params () {

    if [[ ! $offset =~ ^[0-9]+$ ]]; then
        die_with_error "ERROR: Offset $offset is not an integer."
    fi

    if [[ -f /etc/openvpn/${customer_id}-fusion.conf ]]; then
        die_with_error "ERROR: The file /etc/openvpn/${customer_id}-fusion.conf already exists."
    fi

    if [[ -d /etc/openvpn/${customer_id}-easyrsa ]]; then
        die_with_error "ERROR: The directory /etc/openvpn/${customer_id}-easyrsa/ already exists."
    fi

    return 0
}

verify_fusion_installed () {
    if [[ ! -f /opt/fusion/bin/fusion ]]; then
        die_with_error "ERROR: Fusion is not installed at /opt/fusion/bin/fusion"
    fi

    if [[ ( ! -f /etc/opt/ipconfigure.key ) || ( ! -f /etc/opt/ipconfigure.crt ) ]]; then
        die_with_error "ERROR: *.ipconfigure.com key/cert pair not found at /etc/opt/ipconfigure.{key,crt}"
    fi
}

setup_easyrsa () {

    # Install the scripts
    apt-get install -yy -qq openvpn easy-rsa

    # Setup the environment
    cadir="/etc/openvpn/${customer_id}-easyrsa"
    make-cadir $cadir
    cd $cadir

    # Set the CA variables
    sed "s/export KEY_PROVINCE=.*/export KEY_PROVINCE=\"Virginia\"/" -i vars
    sed "s/export KEY_CITY=.*/export KEY_CITY=\"Norfolk\"/" -i vars
    sed "s/export KEY_ORG=.*/export KEY_ORG=\"IPConfigure, Inc.\"/" -i vars
    sed "s/export KEY_EMAIL=.*/export KEY_EMAIL=\"hostmaster@ipconfigure.com\"/" -i vars
    sed "s/export KEY_OU=.*/export KEY_OU=\"Fusion Hosted\"/" -i vars
    sed "s/export KEY_NAME=.*/export KEY_NAME=\"${customer_id}\"/" -i vars

    # Load the variables and reset the environment
    source vars
    ./clean-all

    # Generate all the keys and certs
    ./pkitool --initca
    ./pkitool --server "${customer_id}-fusion"
    ./build-dh
    openvpn --genkey --secret keys/ta.key

    # Keys and certs need to be in /etc/openvpn, so link them there
    cd ..
    ln -s $cadir/keys/ca.crt ${customer_id}-ca.crt
    ln -s $cadir/keys/ca.key ${customer_id}-ca.key
    ln -s $cadir/keys/${customer_id}-fusion.key ${customer_id}-fusion.key
    ln -s $cadir/keys/${customer_id}-fusion.crt ${customer_id}-fusion.crt
    ln -s $cadir/keys/ta.key ${customer_id}-ta.key
    ln -s $cadir/keys/dh2048.pem ${customer_id}-dh2048.pem

    # Generate a public/private keypair here (used by Fusion, not VPN)
    ssh-keygen -f ${customer_id}-fusion-rsa -N ""

    cd /etc/openvpn
    mkdir ${customer_id}-ccd
    touch ${customer_id}-ipp.txt
    touch ${customer_id}-openvpn-status.log
}

add_cloud_ca () {
    cat > /usr/local/share/ca-certificates/fusion-cloud-ca.crt << EOF
-----BEGIN CERTIFICATE-----
MIID8zCCAtugAwIBAgIJAM90dAvpSexLMA0GCSqGSIb3DQEBCwUAMIGPMQswCQYD
VQQGEwJVUzERMA8GA1UECAwIVmlyZ2luaWExEDAOBgNVBAcMB05vcmZvbGsxGjAY
BgNVBAoMEUlQQ29uZmlndXJlLCBJbmMuMRcwFQYDVQQDDA5JUENvbmZpZ3VyZSBD
QTEmMCQGCSqGSIb3DQEJARYXc3VwcG9ydEBpcGNvbmZpZ3VyZS5jb20wHhcNMTcw
MTExMTkzMjQwWhcNMjcwMTA5MTkzMjQwWjCBjzELMAkGA1UEBhMCVVMxETAPBgNV
BAgMCFZpcmdpbmlhMRAwDgYDVQQHDAdOb3Jmb2xrMRowGAYDVQQKDBFJUENvbmZp
Z3VyZSwgSW5jLjEXMBUGA1UEAwwOSVBDb25maWd1cmUgQ0ExJjAkBgkqhkiG9w0B
CQEWF3N1cHBvcnRAaXBjb25maWd1cmUuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOC
AQ8AMIIBCgKCAQEAqxphkCx0ckhpPBPNcvmbZ60hCB1Bvgjr6CoKuifGeDRHRyjb
PHOXvRhX5qY/0jFY9uGMqGgPm68JwO4QHF8MMvcfbK0oGr8RkXs8QCACvBtVdvsH
kfHcoBFrLvLENlJ18o8mPxZApmxvDkVUViJWELaZFOvOLI9lKM8m8A9Qyk6wgLOg
SUcVz9BCO9UEyEDdNmcFplwEFD9oZp5PgKqCR651RWrNUcjLMFfdBwq9FCKniF25
UOGK5d/eBf7WOqyVXFfyDyanjaqjRdrqNBCAip2kFKbtNT91SoB1GWiSJ6a4f00E
CsiG7PkisfHF/rzIJXessru3KQ8w3DqHJAbPbQIDAQABo1AwTjAdBgNVHQ4EFgQU
hHguu8I5am2rrNqkTkI1LG80pCcwHwYDVR0jBBgwFoAUhHguu8I5am2rrNqkTkI1
LG80pCcwDAYDVR0TBAUwAwEB/zANBgkqhkiG9w0BAQsFAAOCAQEABTjPKpyr3hiQ
+QjzxMG9TQrKLEbtYWX0T1LnhbolinT4mepA79AnWW+sQGndwfY6ggFrpMm5yufP
ypQNBggCvU7uz7Zar2O/7Pzpcm2nN/rW4kC3xExtKMMD32uGC7wCRkdFWBLs6dSV
nobjExW0q1leRzmQpPoxXWr3nlqhWGjScu/baLOIIQIbwf42ruRUOag8OsFvo5qG
CXUE3rkhjYmffNlww4ovmpqhrRFitGZ3o3l0GxG+h5LxVoqn7MnX4bRxS+TIEuXj
a1A92CYn2Ve7Xjk7QTWObB3JzhMsTgHWzR7rXw+FBdsI7LHKv6+Wks03pLgBjVXZ
dPpt8Nj5gA==
-----END CERTIFICATE-----
EOF

    update-ca-certificates
}

write_vpn_conf () {
    # Write config file
    cat <<- EOF > /etc/openvpn/${customer_id}-fusion.conf
mode server
tls-server
port ${vpn_port}
proto udp
dev ${vpn_tunnel}
ca ${customer_id}-ca.crt
cert ${customer_id}-fusion.crt
key ${customer_id}-fusion.key
dh ${customer_id}-dh2048.pem
topology subnet
server ${vpn_subnet} 255.255.0.0
ifconfig-pool-persist ${customer_id}-ipp.txt 0
client-config-dir ${customer_id}-ccd
keepalive 10 120
tls-auth ${customer_id}-ta.key 0
key-direction 0
cipher AES-128-CBC
auth SHA256
user nobody
group nogroup
persist-key
persist-tun
status ${customer_id}-openvpn-status.log
verb 3
management 127.0.0.1 ${vpn_mgmt_port}
client-to-client
EOF
}

setup_firewall () {
    apt-get install -yy -qq ufw

    # Enable IP Forwarding
    sed '/net.ipv4.ip_forward=.*/d' -i /etc/sysctl.conf
    echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
    sysctl -p

    # Find default network device
    netdev=$( ip route | grep default | grep -o 'dev.*' | tr -s ' ' | cut -f 2 -d ' ' )

    # Add Firewall rules
    cat <<- EOF > /etc/ufw/before.rules

# BEGIN ${customer_id}-FUSION VPN
*nat
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING -s ${vpn_subnet}/8 -o ${netdev} -j MASQUERADE
COMMIT
# END ${customer_id}-FUSION VPN

$(cat /etc/ufw/before.rules)
EOF

    # Enable IP Forwarding
    sed '/DEFAULT_FORWARD_POLICY=.*/d' -i /etc/default/ufw
    echo 'DEFAULT_FORWARD_POLICY="ACCEPT"' >> /etc/default/ufw

    # Configure firewall
    ufw allow ${vpn_port}/udp
    ufw allow ${fusion_https}/tcp
    ufw allow ${fusion_rtsps}/tcp
    ufw allow ssh
    ufw disable
    ufw --force enable
}

vpn_sanity_check () {
    if systemctl is-active openvpn@${customer_id}-fusion 2>&1 > /dev/null ; then
        echo
        echo "Great news: the openvpn@${customer_id}-fusion service is running!"

        touch /etc/openvpn/offsets.txt
        sed "/^#.*/d" -i /etc/openvpn/offsets.txt
        echo -e "# offset customer_id vpn_port vpn_mgmt_port vpn_subnet vpn_tunnel fusion_https fusion_rtsps\n$( cat /etc/openvpn/offsets.txt )" > /etc/openvpn/offsets.txt
        echo "${offset} ${customer_id} ${vpn_port} ${vpn_mgmt_port} ${vpn_subnet} ${vpn_tunnel} ${fusion_https} ${fusion_rtsps}" >> /etc/openvpn/offsets.txt
    else

        echo
        echo "ERROR: the openvpn@{customer_id}-fusion service is not running!"
        echo
        echo "If you want to undo everything:"
        echo 
        echo "    - sudo systemctl disable openvpn@${customer_id}-fusion"
        echo "    - sudo systemctl stop openvpn@${customer_id}-fusion"
        echo "    - sudo rm -rf /etc/openvpn/${customer_id}*"
        echo "    - Edit /etc/ufw/before.rules to review the ${customer_id}-FUSION section"
        echo "    - Remove ${offset} from /etc/openvpn/offsets.txt"
        echo
        echo "Fix what's broken and try again!"
        exit 1
    fi
}

reset_property () {
    property="$1"
    value="$2"
    file="$3"
    
    sed "/^${property}=.*/d" -i ${file}
    echo "${property}=${value}" >> ${file}
}

setup_fusion () {
    # Copy start-up script and config files

    props_file="/etc/opt/fusion/fusion.properties"

    reset_property "listening.port" "${fusion_https}" "${props_file}"
    reset_property "rtsp.listening.port" "${fusion_rtsps}" "${props_file}"
    reset_property "listening.protocol" "https" "${props_file}"
    reset_property "rtsp.listening.protocol" "rtspst" "${props_file}"
    reset_property "rtsp.proxy.transport.protocol" "tcp" "${props_file}"
    reset_property "ssl.key" "/etc/opt/ipconfigure.key" "${props_file}"
    reset_property "ssl.pem" "/etc/opt/ipconfigure.crt" "${props_file}"
    reset_property "greeting.file.path" \
        "/home/fusion/integrations/steelfin_config/orchid-linux/vpns/agreements/generic_access_agreement.txt" \
        "${props_file}"
}

setup_backups() {
    ln -s ${script_dir}/backup_hosted_config.sh /usr/local/bin/backup_hosted_config.sh
    tmpfile=$(mktemp)
    crontab -l > $tmpfile

    sed -i '/.*backup_hosted_config.sh.*/d' $tmpfile
    echo "0 2 * * * /usr/bin/nice /usr/local/bin/backup_hosted_config.sh" >> $tmpfile

    crontab < $tmpfile
    rm -f $tmpfile
}

setup_killswitch() {
    ln -s ${script_dir}/tools/trial/killswitch.sh /usr/local/bin/killswitch.sh
    tmpfile=$(mktemp)
    crontab -l > $tmpfile

    sed -i '/.*killswitch.sh.*/d' $tmpfile
    echo "0 * * * * /usr/local/bin/killswitch.sh" >> $tmpfile

    crontab < $tmpfile
    rm -f $tmpfile
}

if [[ $# -ne 2 ]]; then
    usage
    exit 1
fi

# First verify that the specified CUSTOMER_ID and OFFSET aren't already in use.
customer_id="$1"
offset="$2"

# Ports and addresses unique to this customer/VPN
vpn_port=$((1000 + $offset))
vpn_mgmt_port=$((2000 + $offset))
vpn_subnet="10.$((8 + $offset)).0.0"
vpn_tunnel="tun$(( 7 + $offset ))"
fusion_https=$((8000 + $offset ))
fusion_rtsps=$((5000 + $offset ))

verify_rootness
verify_params
verify_fusion_installed

# Configure the VPN and firewall
setup_easyrsa
add_cloud_ca
write_vpn_conf
setup_firewall

# Run VPN
systemctl start openvpn@${customer_id}-fusion
systemctl enable openvpn@${customer_id}-fusion

# Verify VPN is running
vpn_sanity_check

# Setup Fusion
setup_fusion
setup_backups
setup_killswitch

systemctl enable fusion
systemctl start fusion

echo "=============================================="
echo "CONFIGURATION COMPLETE! Make sure you forward "
echo "the following ports through the firewall to  "
echo "the Fusion server: "
echo
echo "   VPN: ${vpn_port}/udp"
echo " HTTPS: ${fusion_https}/tdp"
echo "RTSPTS: ${fusion_rtsps}/tdp"
echo
echo "ALSO: Verify that the following DNS entry "
echo "points to this server: "
echo
echo "   ${customer_id}.ipconfigure.com"
echo "=============================================="

