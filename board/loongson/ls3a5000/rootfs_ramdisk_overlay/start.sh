#!/bin/bash

USE_SCREEN=0

while getopts "s" opt; do
    case $opt in
    s)
        USE_SCREEN=1
        ;;
    *)
        echo "Usage: $0 [-s]"
        exit 1
        ;;
    esac
done

if [ ! -e /dev/hvisor ]; then
    echo "hvisor not installed, installing..."
    /install.sh
fi

echo "booting zone linux2 with virtio..."
hvisor zone start /tool/linux2.json

if [ $USE_SCREEN -eq 1 ]; then
    sleep 1
    screen /dev/pts/0
fi
