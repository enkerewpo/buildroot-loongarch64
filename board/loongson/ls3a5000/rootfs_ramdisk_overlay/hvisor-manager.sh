#!/bin/bash

# hvisor-manager.sh - A unified management script for hvisor
# Usage: ./hvisor-manager.sh [command] [options]

# Default configuration
DEFAULT_TOOL_DIR="/tool"
DEFAULT_CONFIG_DIR="/tool"
DEFAULT_LINUX_ID=2
USE_SCREEN=0
USE_VIRTIO=0
VIRTIO_CONFIG=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print colored message
log() {
    local level=$1
    local message=$2
    case $level in
        "info") echo -e "${GREEN}[INFO]${NC} $message" ;;
        "warn") echo -e "${YELLOW}[WARN]${NC} $message" ;;
        "error") echo -e "${RED}[ERROR]${NC} $message" ;;
    esac
}

# Show usage information
show_usage() {
    echo "Usage: $0 [command] [options]"
    echo
    echo "Commands:"
    echo "  install           Install hvisor"
    echo "  start            Start hvisor with zone configuration"
    echo "  daemon           Run hvisor in daemon mode"
    echo "  stop             Stop hvisor zone"
    echo "  restart          Restart hvisor zone"
    echo "  list             List available zones and their status"
    echo "  virtio-start     Start virtio backend"
    echo "  virtio-stop      Stop virtio backend"
    echo
    echo "Options:"
    echo "  -t, --tool-dir   Specify tool directory (default: /tool)"
    echo "  -z, --zone       Specify zone name (required for start command)"
    echo "  -v, --virtio     Enable virtio backend"
    echo "  -c, --config     Specify virtio configuration file"
    echo "  -s, --screen     Use screen for console"
    echo "  -h, --help       Show this help message"
    echo
    echo "Examples:"
    echo "  $0 install -t /custom/tool"
    echo "  $0 start -z linux2 -s"
    echo "  $0 start -z linux2 -v -c /tool/virtio_cfg.json"
}

# Install hvisor
install_hvisor() {
    local tool_dir=$1
    log "info" "Installing hvisor from $tool_dir..."
    cd "$tool_dir" || exit 1
    insmod ./hvisor.ko
    cp ./hvisor /bin
    log "info" "Successfully installed hvisor"
}

# Check if hvisor is installed
check_hvisor() {
    if [ ! -e /dev/hvisor ]; then
        log "warn" "hvisor not installed, installing..."
        install_hvisor "$TOOL_DIR"
    fi
    return 0
}

check_hvisor

# Start virtio backend
start_virtio_backend() {
    local config_file=$1
    check_hvisor
    
    log "info" "Starting virtio backend with configuration: $config_file"
    nohup hvisor virtio start "$config_file" &
    sleep 2  # Wait for virtio backend to initialize
}

# List available zones and their status
list_zones() {
    log "info" "Checking available zone configurations..."
    
    # Check if config directory exists
    if [ ! -d "$CONFIG_DIR" ]; then
        log "error" "Config directory not found: $CONFIG_DIR"
        return 1
    fi
    
    # Get all json files in config directory
    local config_files=("$CONFIG_DIR"/*.json)
    if [ ${#config_files[@]} -eq 0 ]; then
        log "warn" "No zone configurations found in $CONFIG_DIR"
        return 1
    fi
    
    # Print header
    printf "\n%-20s %-15s %-10s\n" "ZONE NAME" "STATUS" "CONFIG FILE"
    printf "%-20s %-15s %-10s\n" "--------------------" "---------------" "----------"
    
    # Check each configuration
    for config in "${config_files[@]}"; do
        local zone_name=$(basename "$config" .json)
        local status="Not Running"
        
        # Check if zone is running
        if hvisor zone list | grep -q "$zone_name"; then
            status="Running"
        fi
        
        printf "%-20s %-15s %-10s\n" "$zone_name" "$status" "$(basename "$config")"
    done
    
    printf "\nTotal zones: %d\n" ${#config_files[@]}
}

# Validate zone configuration
validate_zone() {
    local zone_name=$1
    local config_file="$CONFIG_DIR/${zone_name}.json"
    
    # Check if config file exists
    if [ ! -f "$config_file" ]; then
        log "error" "Zone configuration not found: $config_file"
        
        # List available zones
        log "info" "Available zones:"
        local available_zones=("$CONFIG_DIR"/*.json)
        if [ ${#available_zones[@]} -eq 0 ]; then
            log "warn" "No zone configurations found in $CONFIG_DIR"
        else
            for zone in "${available_zones[@]}"; do
                log "info" "  - $(basename "$zone" .json)"
            done
        fi
        return 1
    fi
    
    return 0
}

# Start hvisor zone
start_zone() {
    local zone_name=$1
    local use_screen=$2
    
    log "info" "Starting zone: $zone_name"
    
    # Validate zone configuration
    if ! validate_zone "$zone_name"; then
        exit 1
    fi
    
    local config_file="$CONFIG_DIR/${zone_name}.json"
    log "info" "Using configuration: $config_file"
    
    # Start zone
    run_cmd "hvisor zone start \"$config_file\""
    
    if [ $use_screen -eq 1 ]; then
        log "info" "Attaching to zone console, caution, we are openning pts 0..."
        sleep 1
        run_cmd "screen /dev/pts/0" 
    fi
}

# Stop hvisor zone
stop_zone() {
    local zone_name=$1
    
    log "info" "Stopping zone: $zone_name"
    
    # Validate zone configuration
    if ! validate_zone "$zone_name"; then
        exit 1
    fi
    
    run_cmd "hvisor zone stop \"$zone_name\""
}

# Parse command line arguments
COMMAND=""
TOOL_DIR=$DEFAULT_TOOL_DIR
ZONE_NAME=""
USE_VIRTIO=0
VIRTIO_CONFIG=""

# If no arguments provided, show usage
if [ $# -eq 0 ]; then
    show_usage
    exit 1
fi

# Parse command
case "$1" in
    "install"|"start"|"daemon"|"stop"|"restart"|"list"|"virtio-start"|"virtio-stop")
        COMMAND=$1
        shift
        ;;
    *)
        log "error" "Unknown command: $1"
        show_usage
        exit 1
        ;;
esac

# Parse options
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--tool-dir)
            TOOL_DIR="$2"
            shift 2
            ;;
        -z|--zone)
            ZONE_NAME="$2"
            shift 2
            ;;
        -v|--virtio)
            USE_VIRTIO=1
            shift
            ;;
        -c|--config)
            VIRTIO_CONFIG="$2"
            shift 2
            ;;
        -s|--screen)
            USE_SCREEN=1
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            log "error" "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validate required parameters
if [ "$COMMAND" = "start" ] && [ -z "$ZONE_NAME" ]; then
    log "error" "Zone name is required for start command"
    show_usage
    exit 1
fi

if [ $USE_VIRTIO -eq 1 ] && [ -z "$VIRTIO_CONFIG" ]; then
    log "error" "Virtio configuration file is required when virtio backend is enabled"
    show_usage
    exit 1
fi

# Execute command
case $COMMAND in
    "install")
        install_hvisor "$TOOL_DIR"
        ;;
    "start")
        if [ $USE_VIRTIO -eq 1 ]; then
            start_virtio_backend "$VIRTIO_CONFIG"
        fi
        start_zone "$ZONE_NAME" "$USE_SCREEN"
        ;;
    "stop")
        stop_zone "$ZONE_NAME"
        ;;
    "restart")
        stop_zone "$ZONE_NAME"
        sleep 2
        if [ $USE_VIRTIO -eq 1 ]; then
            start_virtio_backend "$VIRTIO_CONFIG"
        fi
        start_zone "$ZONE_NAME" "$USE_SCREEN"
        ;;
    "list")
        list_zones
        ;;
    "virtio-start")
        if [ -z "$VIRTIO_CONFIG" ]; then
            log "error" "Configuration file is required for virtio-start command"
            exit 1
        fi
        start_virtio_backend "$VIRTIO_CONFIG"
        ;;
    "virtio-stop")
        echo "virtio-stop is not supported yet"
        exit 1
        ;;
esac 