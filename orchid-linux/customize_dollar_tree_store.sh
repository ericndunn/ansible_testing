#!/bin/bash

# Set up Dollar Tree-specific Configuration
# RCT 2/15/2017

failhard()
{
	echo "================================="
	echo "$1"
	echo "================================="
	cat
}

CURDIR=`dirname "$0"`
cd $CURDIR
SCRIPT_DIR=`pwd -L`

if [[ $USER == "orchid" ]]; then
    sudo bash -c 'echo "
orchid.max_player_count = 4" >> /etc/opt/orchid_server.properties'

    sudo systemctl stop orchid.service
    sudo mkdir /home/orchives
    sudo rm -rf /orchives
    sudo ln -s /home/orchives /orchives
    sudo systemctl start orchid.service

    # Disable bluetooth
    sudo bash -c 'echo "install net-pf-31 /bin/false
install bluetooth /bin/false" >> /etc/modprobe.d/bluetooth.conf'

    # Install puppet
    sudo rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
    sudo yum -y install puppet-agent

    sudo bash -c "echo '[main]
server = chesva500.dollartree.com
environment = production' > /etc/puppetlabs/puppet/puppet.conf "

    # We want to set a static IP on the network interface.
    # We'll pick the one that has internet access.
    
    iface=$(ip route get 8.8.8.8 | tr -s ' ' | cut -d ' ' -f 5)
    iface_cfg=/etc/sysconfig/network-scripts/ifcfg-${iface}

    if [[ ! -f $iface_cfg ]] ; then
        failhard "Can't configure interface ${iface}.  Sorry."
    fi
    
    sudo sed -i '/DOMAIN=/d' $iface_cfg
    sudo sed -i '/DOMAIN=.*/d' $iface_cfg
    sudo sed -i '/IPV4_FAILURE_FATAL=.*/d' $iface_cfg
    sudo sed -i '/IPV6INIT=.*/d' $iface_cfg
    sudo sed -i '/IPV6_AUTOCONF=.*/d' $iface_cfg
    sudo sed -i '/IPV6_DEFROUTE=.*/d' $iface_cfg
    sudo sed -i '/IPV6_PEERDNS=.*/d' $iface_cfg
    sudo sed -i '/IPV6_PEERROUTES=.*/d' $iface_cfg
    sudo sed -i '/IPV6_FAILURE_FATAL=.*/d' $iface_cfg
    sudo sed -i '/IPADDR=.*/d' $iface_cfg
    sudo sed -i '/GATEWAY=.*/d' $iface_cfg
    sudo sed -i '/NETMASK=.*/d' $iface_cfg
    sudo sed -i '/DNS1=.*/d' $iface_cfg
    sudo sed -i '/ONBOOT=.*/d' $iface_cfg
    sudo sed -i '/BOOTPROTO=.*/d' $iface_cfg

    tmpfile=`mktemp`
    echo 'DOMAIN="dollartree.com"
IPV4_FAILURE_FATAL="no"
IPV6INIT="no"
IPV6_AUTOCONF="no"
IPV6_DEFROUTE="no"
IPV6_PEERDNS="no"
IPV6_PEERROUTES="no"
IPV6_FAILURE_FATAL="no"
IPADDR=192.168.0.250
GATEWAY=192.168.0.253
NETMASK=255.255.255.0
DNS1=10.10.3.98
ONBOOT="yes"
BOOTPROTO="static"' > $tmpfile

    sudo bash -c "cat $tmpfile >> $iface_cfg"
    rm $tmpfile

    sudo sed -i 's/SELINUX=.*/SELINUX=permissive/' /etc/selinux/config
fi

# Remove Teamviewer
sudo rm -f ~/.local/share/applications/teamviewer.desktop
sudo rm -f ~/Desktop/teamviewer.desktop
sudo rm -rf /opt/teamviewerqs

# Add some users requested by Bailiwick (see ticket 17644 from Travis Earls)
# Add 'DTS_Advanced' user to Orchid
curl -H "Content-Type: application/json" \
     -X POST \
     -d '{"username":"DTS_Advanced","password":"3Xp3rt!","role":"Manager"}' \
     -u admin:0rc#1d \
     "http://localhost/service/users"

# Add 'DTS_Admin' user to Orchid
curl -H "Content-Type: application/json" \
     -X POST \
     -d '{"username":"DTS_Admin","password":"VMS@dm$","role":"Administrator"}' \
     -u admin:0rc#1d \
     "http://localhost/service/users"

    # Add 'Manager' user to Orchid
curl -H "Content-Type: application/json" \
     -X POST \
     -d '{"username":"Manager","password":"smVwr1","role":"Viewer"}' \
     -u admin:0rc#1d \
     "http://localhost/service/users"

    # Add 'I3dvr' user to Orchid
curl -H "Content-Type: application/json" \
     -X POST \
     -d '{"username":"I3dvr","password":"W@tchM3n","role":"Administrator"}' \
     -u admin:0rc#1d \
     "http://localhost/service/users"

# Force the monitor to not go to sleep
echo \
'!#/bin/sh

xset -display $DISPLAY s off -dpms' > ~/.xsessionrc
chmod 755 ~/.xsessionrc
