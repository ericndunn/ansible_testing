#!/bin/bash

raid_device=/dev/md127

notify_all() {
    if [[ -f /etc/redhat-release ]]; then
        notify_redhat "$@"
    elif [[ -f /etc/debian_version ]]; then
        notify_ubuntu "$@"
    fi
}

notify_ubuntu() {
    local notify_opts="$1"
    local title="$2"
    local msg="$3"
    local popup=$4
    
    who | rev | uniq -f 5 | rev | awk '{print $1, $NF}' | tr -d "()" |
    while read u d; do
        id=$(id -u $u)
        . /run/user/$id/dbus-session 2> /dev/null
        export DBUS_SESSION_BUS_ADDRESS
        export DISPLAY=$d
        su $u -c "/usr/bin/notify-send $notify_opts '$title' '$msg'"

        if [[ $popup -gt 0 ]]; then
            # If there are any open zenity dialogs, kill them now
            for zenity_pid in $(ps auwx | grep "su $u" | grep zenity | tr -s ' ' | cut -d ' ' -f 2); do
                kill $zenity_pid
            done
            su $u -c "/usr/bin/zenity --error --text '<b>$title</b>\n\n$msg'" &
        fi
    done 
}

notify_redhat() {
    true 
}

status="$1"

if [[ $status == "DegradedArray" ]]; then
    # Is RAID rebuilding?
    if sudo mdadm --detail ${raid_device} | grep "Rebuild Status" &> /dev/null; then
        notify_opts="-t 10000 \
            -u critical \
            -c device.error \
            -i /usr/share/icons/HighContrast/48x48/devices/drive-harddisk.png"
        title="Video Storage is Rebuilding"
        em_sp=" " 
        details="$(sudo mdadm --detail ${raid_device} | egrep 'Rebuild Status' | sed "s/%/％/g")"
        msg="$(printf "Your Orchid server RAID array is rebuilding.\n${em_sp}""
${details}")"
        popup=0
    else
        # RAID is failed
        notify_opts="-t 10000 \
            -u critical \
            -c device.error \
            -i /usr/share/icons/HighContrast/48x48/status/computer-fail.png" 
        title="Critical Video Storage Error!"
        em_sp=" " 
        details="$(sudo mdadm --detail ${raid_device} | egrep '(State :|(Raid|Working) Devices)' | sed 's/^[ \t]*//g')"
        msg="$(printf "Your Orchid server RAID (video storage hard drive) array is degraded.\n${em_sp}\nPlease contact your video server service provider <b>immediately</b> to avoid data loss!\n${em_sp}\n${details}")"
        popup=1
    fi
fi

notify_all "$notify_opts" "$title" "$msg" $popup
