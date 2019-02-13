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

    # * Disable apport
    sudo sed -i 's/enabled=1/enabled=0/' /etc/default/apport
    sudo service apport restart

    # Remove and create orchid_viewer user
    sudo userdel orchid_viewer
    sudo rm -rf /home/orchid_viewer
    sudo useradd -m -s /bin/bash orchid_viewer
    echo -e "0rc#1d\n0rc#1d" | (sudo passwd orchid_viewer)

    # Set orchid_viewer to auto login
    sudo bash -c 'echo "[SeatDefaults]
    autologin-user=orchid_viewer
    allow-guest=false" > /etc/lightdm/lightdm.conf'

    # Disable automatic updates
    # sudo sed -i 's/^/#/' /etc/apt/sources.list

    # Don't let the unwashed masses into orchives
    sudo chmod 700 /orchives

    # NTP inbound
    sudo iptables -A INPUT -s 192.168.2.0/24 -p udp -m udp --dport 123 -j ACCEPT
    sudo iptables -A INPUT -s 127.0.0.0 -p udp -m udp --dport 123 -j ACCEPT
    sudo iptables -A INPUT -p udp -m udp --dport 123 -j DROP

    # Add 'Staff' user to Orchid
    curl -H "Content-Type: application/json" \
         -X POST \
         -d '{"username":"Staff","password":"MCd01","role":"Viewer"}' \
     -u admin:0rc#1d \
         "http://localhost/service/users"

    # Add 'StoreMgr' user to Orchid
    curl -H "Content-Type: application/json" \
         -X POST \
         -d '{"username":"StoreMgr","password":"MCd02","role":"Manager"}' \
     -u admin:0rc#1d \
         "http://localhost/service/users"

    # Add 'GM' user to Orchid
    curl -H "Content-Type: application/json" \
         -X POST \
         -d '{"username":"GM","password":"MCd03","role":"Manager"}' \
     -u admin:0rc#1d \
         "http://localhost/service/users"

    # Add 'GM' user to Orchid
    curl -H "Content-Type: application/json" \
         -X POST \
         -d '{"username":"Admin1","password":"MCd04","role":"Administrator"}' \
     -u admin:0rc#1d \
         "http://localhost/service/users"

    # Add 'ipc_service' user to Orchid
    curl -H "Content-Type: application/json" \
         -X POST \
         -d '{"username":"ipc_service","password":"ipc0nfigur3grimace","role":"Administrator"}' \
     -u admin:0rc#1d \
         "http://localhost/service/users"

    sudo sed -i '/^archivecleaner.usedspace.percentage = 85/d' /etc/opt/orchid_server.properties
    sudo bash -c 'echo "archivecleaner.usedspace.percentage = 97" >> /etc/opt/orchid_server.properties'

    sudo sed -i '/^orchid.max.player_count/d' /etc/opt/orchid_server.properties
    sudo bash -c 'echo "orchid.max_player_count = 16" >> /etc/opt/orchid_server.properties'

    sudo sed -i '/^rtsp.rtp_port_range.min/d' /etc/opt/orchid_server.properties
    sudo bash -c 'echo "rtsp.rtp_port_range.min = 10000" >> /etc/opt/orchid_server.properties'

    sudo sed -i '/^rtsp.rtp_port_range.max/d' /etc/opt/orchid_server.properties
    sudo bash -c 'echo "rtsp.rtp_port_range.max = 20000" >> /etc/opt/orchid_server.properties'
fi

movies=(    "IPConfigure Archive Training Video.mov"
            "IPConfigure Video Export Training.mov"
            "Wachter IPConfigure Live View Training.mov" )

chmod 755 ~/Desktop
chmod 644 ~/Desktop/*.mov
for movie in "${movies[@]}"; do
    curl "http://download.ipconfigure.com/misc/${movie}" > ~/Desktop/"${movie}"
done
chmod 444 ~/Desktop/*.mov
chmod 555 ~/Desktop

MCDS_PUBKEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDqFVq4kfriZSFeBcS/Y4g4rLGwSvAk4BZy8C76l8gVN7tLZc4UxDWLWiBILUwd+TNYyJ3l4MjDSUvF6hahfmNTT4Osn+YqMeUfzHBx/b7XtaNYQeey9ZkeD7mEy/+HqyyDzaQa0FoerdAQR6KklPh47LzvjLySVG0ahtOuOuzNPMOsZWPrWmsynnrEEd13GRBIYfvignHCiUWkxlDA9j19VtslBMeKQXN1o5S/r1cBF4aw5XF8W0+zBEfBQoHcbt6waBKIrjaHS6vDjnGuQfcKVDxkEHZQqJDJr3v/OGyFQu8HuOUKj4Hbpz8k1/yhL7FzvK1mbetbYrN4EDRw0iyv cort@cort-ubuntu"

# Add McDs public key
mkdir -p ~/.ssh
echo "$MCDS_PUBKEY" >> ~/.ssh/authorized_keys

# Force the monitor to not go to sleep
echo \
'!#/bin/sh

xset -display $DISPLAY s off -dpms' > ~/.xsessionrc
chmod 755 ~/.xsessionrc

# Install graceful shutdown script
if [[ $USER == "orchid" ]]; then
    sudo apt install libusb-dev libssl-dev g++
    sudo apt update

    pushd .
    cd $HOME
    tar xvfz ${SCRIPT_DIR}/orchid_install_files/ipcbase-nut.tar.gz
    cd nut-2.7.1-ipconfig
    ./configure
    sudo make -j 11 install
    cd ..
    rm -rf nut-2.7.1-ipconfig

    cd /
    sudo tar xvfz ${SCRIPT_DIR}/orchid_install_files/ipcsupp-nut.tar.gz

    cd /etc/init.d
    sudo update-rc.d nut defaults
    sudo update-rc.d nut enable

    halt_patch=$( mktemp )
    cat << EOF > $halt_patch
EOF

    sudo patch -lNp0 < $halt_patch
    rm -f $halt_patch

    sudo chmod 666 /dev/bus/usb/001/004
    sudo mkdir -p /var/state
    sudo chmod 777 /var/state
    sudo mkdir -p /var/state/ups
    sudo chmod 777 /var/state/ups

    rule_temp=$( mktemp )
    cat << EOF > $rule_temp
SUBSYSTEM=="usb", ATTR{idVendor}=="09ae", ATTR{idProduct}=="4004", MODE:="0666"
EOF
    sudo mv $rule_temp /etc/udev/rules.d/usb.rules

    popd

fi
