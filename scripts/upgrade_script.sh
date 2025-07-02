#!/bin/sh

# Include the configuration file

CONFIG_DIR="/usr/local/etc/fbj"

CONFIG_FILE_USER="$CONFIG_DIR/fbj.conf"
CONFIG_FILE_SYSTEM="$CONFIG_DIR/fbj-system.conf"

if [ -f "$CONFIG_FILE_USER" ] && [ -f "$CONFIG_FILE_SYSTEM" ]; then
    . "$CONFIG_FILE_USER"
    . "$CONFIG_FILE_SYSTEM"
else
    printf "Configuration file not found"
    exit 1
fi

upgrade_jail() {
    jail_name="$1"
    release="$2"
    
    freebsd-update -j $jail_name -r $release upgrade
    freebsd-update -j $jail_name install
    service jail restart $jail_name
    freebsd-update -j $jail_name install
    service jail restart $jail_name
    pkg -j $jail_name upgrade -f
    service jail restart $jail_name
}

# Main

jail_name="$1"
release="$2"

upgrade_jail $jail_name $release