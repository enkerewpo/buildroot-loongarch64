#!/bin/bash

# Default configuration file
CONFIG_FILE="/tool/virtio_cfg.json"

# Check if a parameter is provided
if [ $# -gt 0 ]; then
    case "$1" in
        "blk")
            CONFIG_FILE="/tool/virtio_cfg_blk.json"
            ;;
        "console")
            CONFIG_FILE="/tool/virtio_cfg_console.json"
            ;;
        *)
            echo "Usage: $0 [blk|console]"
            echo "  blk     - Use block device configuration"
            echo "  console - Use console configuration"
            echo "  no args - Use default configuration (both block and console)"
            exit 1
            ;;
    esac
fi

# check whether /dev/hvisor exists, if not, run /install.sh
if [ ! -e /dev/hvisor ]; then
    echo "hvisor not installed, installing..."
    /install.sh
fi

mkdir -p /dev/pts
mount -t devpts devpts /dev/pts

cp -r libdrm-install/lib/* /lib64/

echo "Starting hvisor with configuration: $CONFIG_FILE"
nohup hvisor virtio start "$CONFIG_FILE" &

# spawn a process to monitor nohup.out
# /mon.sh &