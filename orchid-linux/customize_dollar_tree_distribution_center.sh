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

# Disable bluetooth
sudo bash -c 'echo "install net-pf-31 /bin/false
install bluetooth /bin/false" >> /etc/modprobe.d/bluetooth.conf'

# Install puppet
sudo rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
sudo yum -y install puppet-agent

sudo bash -c "echo '[main]
server = chesva500.dollartree.com
environment = production' > /etc/puppetlabs/puppet/puppet.conf "

sudo sed -i 's/SELINUX=.*/SELINUX=permissive/' /etc/selinux/config

# Remove Teamviewer
sudo rm -f ~/.local/share/applications/teamviewer.desktop
sudo rm -f ~/Desktop/teamviewer.desktop
sudo rm -rf /opt/teamviewerqs
