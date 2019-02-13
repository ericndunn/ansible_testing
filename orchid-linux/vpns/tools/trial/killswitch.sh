#!/bin/bash

current_ptime=$( date +%s )
kill_file=/home/fusion/KILLTIME

if [[ -f ${kill_file} ]] && [[ $current_ptime -gt $( cat ${kill_file} ) ]]; then
    /sbin/shutdown -h now    
fi

