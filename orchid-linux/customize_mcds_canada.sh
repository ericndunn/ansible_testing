#!/bin/bash

# Set up McDonald's-specific Configuration
# RCT 10/3/2016

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
orchid.max_player_count = 16" >> /etc/opt/orchid_server.properties'

fi

# Force the monitor to not go to sleep
echo \
'!#/bin/sh

xset -display $DISPLAY s off -dpms' > ~/.xsessionrc
chmod 755 ~/.xsessionrc

# Install UPS components
sudo apt-get install -yy nut nut-monitor

# Copy rules that will allow udev to recognize a plugged-in Liebert GXT4
# as a UPS device.  NOTE: The source file here has an extra line added to it
# and is different from the one installed in /lib/udev/rules.d/.
sudo cp ${SCRIPT_DIR}/orchid_install_files/canada_ups/*-nut-usbups.rules /etc/udev/rules.d/

# nut-server, nut-client
sudo cp ${SCRIPT_DIR}/orchid_install_files/canada_ups/orchid_ups_notify.sh /usr/local/bin/
sudo cp ${SCRIPT_DIR}/orchid_install_files/canada_ups/{ups*,nut}.conf /etc/nut
sudo chown root.nut /etc/nut/*
sudo chmod 640 /etc/nut/*

sudo service udev reload
sudo service nut-server start
sudo service nut-client start
