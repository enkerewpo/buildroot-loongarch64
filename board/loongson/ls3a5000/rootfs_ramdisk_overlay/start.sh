#!/bin/bash

USE_SCREEN=0
CONFIG_FILE="/tool/linux2.json"

show_usage() {
    echo "Usage: $0 [-s] [config]"
    echo "  -s        - Use screen for console"
    echo "  config    - Configuration to use:"
    echo "              no_virtio - Use configuration without virtio devices"
    echo "              console   - Use configuration with console"
    echo "              blk       - Use configuration with block device"
    echo "              default   - Use default configuration (with virtio devices)"
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

# Check if a configuration parameter is provided
if [ $# -gt 0 ]; then
    case "$1" in
        "no_virtio")
            CONFIG_FILE="/tool/linux2_no_virtio.json"
            ;;
        "console")
            CONFIG_FILE="/tool/linux2_console.json"
            ;;
        "blk")
            CONFIG_FILE="/tool/linux2_blk.json"
            ;;
        "default")
            CONFIG_FILE="/tool/linux2.json"
            ;;
        *)
            # Skip the -s option if it was used
            if [ "$1" != "-s" ]; then
                echo "Unknown configuration: $1"
                show_usage
            fi
            ;;
    esac
fi

if [ ! -e /dev/hvisor ]; then
    echo "hvisor not installed, installing..."
    /install.sh
fi

echo "booting zone linux2 with configuration: $CONFIG_FILE"
hvisor zone start "$CONFIG_FILE"

if [ $USE_SCREEN -eq 1 ]; then
    sleep 1
    screen /dev/pts/0
fi
