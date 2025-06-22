#!/bin/sh

# Include the configuration file
. ./conf/fbj-system.conf

# create directories
create_directory() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
    fi
}

# Main

# fbj paths

CONFIG_DIR="/usr/local/etc/fbj"

# if not root...
if [ "$(id -u)" -ne 0 ]; then
    echo ""
    echo "Please run this script as root to install fbj"
    echo ""
    exit 1
fi


create_directory "$MAIN_SCRIPT_DIR"
create_directory "$CONFIG_DIR"

# Copy scripts and utilities
cp fbj "$MAIN_SCRIPT_DIR/"
cp conf/* "$CONFIG_DIR/"
cp -r scripts "$CONFIG_DIR"
cp -r utilities "$CONFIG_DIR"

# make it executable
chmod +x "$MAIN_SCRIPT_DIR"/fbj
chmod +x "$SCRIPTS_DIR"/*.sh
chmod +x "$UTILITIES_DIR"/utility*

echo "fbj installed successfully."
