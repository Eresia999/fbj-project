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

# if not root...
if [ "$(id -u)" -ne 0 ]; then
    echo ""
    echo "Please run this script as root to install fbj"
    echo ""
    exit 1
fi


create_directory "$MAIN_SCRIPT_DIR"
create_directory "$CONFIG_DIR"
create_directory "$FBJ_DIR"

# Copy scripts and utilities
cp fbj "$MAIN_SCRIPT_DIR"/
cp -r conf/* "$CONFIG_DIR"/
cp -r scripts "$FBJ_DIR"/
cp -r utilities "$FBJ_DIR"/

echo "fbj installed successfully."
