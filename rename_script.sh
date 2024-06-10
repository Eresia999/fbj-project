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

# Verifica che sia stato fornito un nome per il jail come argomento
if [ -z "$1" ]; then
    echo "Usage: $0 rename <jail_name>"
    exit 1
fi

# Main
jail_name="$1"
new_name="$2"

if [ -z "$new_name" ]; then
    new_name="$jail_name-backup"
fi

# Stop the jail
sh $JAIL_BOOT stop $jail_name

if zfs list "$JAIL_ZDIR/$jail_name" >/dev/null 2>&1; then
    zfs rename $JAIL_ZDIR/$jail_name $JAIL_ZDIR/$new_name
    if zfs list "$JAIL_ZDIR/$new_name" >/dev/null 2>&1; then
        echo "Dataset renamed successfully!"
        echo "New dataset: $JAIL_ZDIR/$new_name"
        mv "$JAIL_CONF_DIR/$jail_name.conf" "$JAIL_CONF_DIR/$new_name.conf"
        echo "New configuration file: $JAIL_CONF_DIR/$new_name.conf"
    else
        echo "Failed to rename dataset: $JAIL_ZDIR/$jail_name"
    fi
fi