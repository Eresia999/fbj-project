#!/bin/sh

# Include the configuration file

FBJ_DIR="/usr/local/etc/fbj"

if [ -d "~/.local/share/fbj" ]; then
    FBJ_DIR="$HOME/.local/share/fbj"
fi

CONFIG_FILE_USER="$FBJ_DIR/fbj.conf"

if [ -f "$CONFIG_FILE_USER" ]; then
    . "$CONFIG_FILE_USER"
else
    echo "Configuration file not found: $CONFIG_FILE_USER"
    echo "Please install fbj: ./install.sh"
    exit 1
fi

# update scripts and utilities
cp fbj "$MAIN_SCRIPT_DIR/"
cp scripts "$FBJ_DIR/"
cp utility "$FBJ_DIR/"
cp fbj-system.conf "$FBJ_DIR/"

# make it executable
chmod +x "$MAIN_SCRIPT_DIR/fbj"
chmod +x "$SCRIPTS_DIR"/*.sh
chmod +x "$UTILITIES_DIR"/utility*

echo "Upgrade complete"