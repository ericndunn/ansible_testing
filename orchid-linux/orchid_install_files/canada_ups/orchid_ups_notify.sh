#!/bin/bash

case $1 in
    upsgone)
        logger -t upssched-cmd "The UPS has been gone for awhile"
        ;;
    *)
        logger -t upssched-cmd "==> $@ <== "
        ;;
esac

