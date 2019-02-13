#!/bin/bash

# Force the monitor to not go to sleep
echo \
'!#/bin/sh

xset -display $DISPLAY s off -dpms' > ~/.xsessionrc
chmod 755 ~/.xsessionrc

