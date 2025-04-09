#!/bin/bash

set -e

# ARG1: workspace root
# ARG2: target output folder

ARG1=${1:-$(pwd)}
WORKSPACE=$(realpath "$ARG1")
if [ ! -d "$WORKSPACE" ]; then
    echo "Workspace root $ARG1 does not exist"
    exit 1
fi
echo "Workspace root: $ARG1"
if [ ! -d "$2" ]; then
    echo "Target output folder $2 does not exist"
    exit 1
fi
echo "Target output folder: $2"

# cp all *.ext4 to target output folder
cp -r -v "$WORKSPACE"/*.ext4 "$2"

echo "Copy disk images to $2 successfully!"