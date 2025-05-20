#!/bin/bash

USE_SCREEN=0
LINUX_ID=2 # Default to linux2

show_usage() {
    echo "Usage: $0 [-s] [id]"
    echo "  -s        - Use screen for console"
    echo "  id        - Linux instance to start (1, 2, or 3)"
    echo "              Default: 1"
    exit 1
}

while getopts "s" opt; do
    case $opt in
    s)
        USE_SCREEN=1
        ;;
    *)
        show_usage
        ;;
    esac
done

# Check if a Linux ID is provided
if [ $# -gt 0 ]; then
    # Skip the -s option if it was used
    if [ "$1" != "-s" ]; then
        case "$1" in
        "1" | "2" | "3")
            LINUX_ID=$1
            ;;
        *)
            echo "Invalid Linux ID: $1"
            show_usage
            ;;
        esac
    fi
fi

if [ ! -e /dev/hvisor ]; then
    echo "hvisor not installed, installing..."
    /install.sh
fi

CONFIG_FILE="/tool/linux${LINUX_ID}.json"
echo "booting zone linux${LINUX_ID} with configuration: $CONFIG_FILE"
hvisor zone start "$CONFIG_FILE"

if [ $USE_SCREEN -eq 1 ]; then
    sleep 1
    screen /dev/pts/0
fi
