#!/bin/sh

# Include the configuration file
. ./conf/fbj.conf

# create directories
create_directory() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
    fi
}

# Main

# fbj paths
MAIN_SCRIPT_DIR="/usr/local/bin"
SCRIPTS_DIR="/usr/local/share/fbj/scripts"
UTILITIES_DIR="/usr/local/share/fbj/utilities"
CONFIG_DIR="/usr/local/etc/fbj"

# if not root...
if [ "$(id -u)" -ne 0 ]; then
    echo "You are not root. This script will be installed just for your user."
    echo "Please run this script as root to install fbj globally"
    echo "or you need to execute the script with sudo or similar."
    
    MAIN_SCRIPT_DIR="~/.local/bin"
    SCRIPTS_DIR="~/.local/share/fbj/scripts"
    UTILITIES_DIR="~/.local/share/fbj/utilities"
    CONFIG_DIR="~/.local/share/fbj"
fi


create_directory "$MAIN_SCRIPT_DIR"
create_directory "$CONFIG_DIR"

# Copy scripts and utilities
cp fbj "$MAIN_SCRIPT_DIR/"
cp conf/ "$CONFIG_DIR/"
cp scripts "$CONFIG_DIR"
cp utilities "$CONFIG_DIR"

# make it executable
chmod +x "$MAIN_SCRIPT_DIR/fbj"
chmod +x "$SCRIPTS_DIR"/*.sh
chmod +x "$UTILITIES_DIR"/utility*

# copy paths in the configuration file
cat << EOF >> "$CONFIG_DIR/fbj.conf"

# fbj paths
MAIN_SCRIPT_DIR="$MAIN_SCRIPT_DIR"
SCRIPTS_DIR="$SCRIPTS_DIR"
UTILITIES_DIR="$UTILITIES_DIR"
EOF

echo "fbj installed successfully."
