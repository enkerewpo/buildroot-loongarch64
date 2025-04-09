#!/bin/bash

set -e

# ARG1: workspace root

ARG1=${1:-$(pwd)}
WORKSPACE=$(realpath "$ARG1")
echo "Workspace root: $ARG1"

build_ext4() {
    local dir="$1"
    local workspace="$2"
    local disk_name="${dir##*/}.ext4"
    # we make all files under dir into a single ext4 image
    # 1. create an ext4 image with 64MB size
    # 2. mount to a temp dir
    # 3. copy all files under dir to the temp dir
    # 4. unmount the temp dir

    sudo rm -f "$disk_name"
    sudo dd if=/dev/zero of="$disk_name" bs=1M count=8
    sudo mkfs.ext4 "$disk_name"
    local temp_dir=$(mktemp -d)
    sudo mount "$disk_name" "$temp_dir"
    # copy all files under dir to the temp dir
    sudo cp -r "$dir"/* "$temp_dir"
    sudo sync
    sudo umount "$temp_dir"
    sudo rmdir "$temp_dir"
    # check if the disk image is created successfully
    if [ -f "$disk_name" ]; then
        echo "Disk image $disk_name created successfully!"
    else
        echo "Failed to create disk image $disk_name"
        exit 1
    fi
}

# iterate all dirs name under $WORKSPACE
for dir in "$WORKSPACE"/*; do
    if [ -d "$dir" ]; then
        echo "Building disk for $dir"
        build_ext4 "$dir" "$WORKSPACE"
    fi
done 