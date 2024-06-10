#!/bin/sh

# Include il file di configurazione se esiste
CONFIG_FILE_USER="/usr/local/etc/fbj/fbj.conf"
CONFIG_FILE_SYSTEM="/usr/local/etc/fbj/fbj-system.conf"
if [ -f "$CONFIG_FILE_USER" ] && [ -f "$CONFIG_FILE_SYSTEM" ]; then
    . "$CONFIG_FILE_USER"
    . "$CONFIG_FILE_SYSTEM"
else
    echo "Configuration file not found"
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