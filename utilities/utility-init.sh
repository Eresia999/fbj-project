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

sysrc jail_enable="YES"
sysrc jail_list+=""

printf "Do you need custom devfs.rules? [y/N]\n"
read a_cds

case "$a_cds" in
  [Yy] | [Yy][Ee][Ss]) 
        if [ -n "$CUSTOM_DEVFS_RULES" ]; then
            ee "$CUSTOM_DEVFS_RULES"
            cp "$CUSTOM_DEVFS_RULES" /etc/devfs.rules
            service devfs restart
        else
            printf "CUSTOM_DEVFS_RULES is not set.\n"
        fi
    ;;
  *) 
    printf "NO custom devfs.rules\n"
    ;;
esac

if [ -z "$JAIL_ZMOUNTPOINT" ] || [ -z "$JAIL_MOUNTPOINT" ] || [ -z "$JAIL_ZMEDIA" ] || [ -z "$JAIL_ZDIR" ]; then
    printf "Error: Some variables are not set."
    exit 1
fi

if ! zfs list "$JAIL_ZMOUNTPOINT" >/dev/null 2>&1; then
    zfs create -o mountpoint="$JAIL_MOUNTPOINT" "$JAIL_ZMOUNTPOINT"
fi

if ! zfs list "$JAIL_ZMEDIA" >/dev/null 2>&1; then
    zfs create "$JAIL_ZMEDIA"
    if [ "$MEDIA_DIR" != "$JAIL_MOUNTPOINT/media" ]; then
        zfs set mountpoint="$MEDIA_DIR" "$JAIL_ZMEDIA"
    fi
fi

if ! zfs list "$JAIL_ZDIR" >/dev/null 2>&1; then
    zfs create "$JAIL_ZDIR"
    if [ "$JAIL_DIR" != "$JAIL_MOUNTPOINT/containers" ]; then
        zfs set mountpoint="$JAIL_DIR" "$JAIL_ZDIR"
    fi
fi