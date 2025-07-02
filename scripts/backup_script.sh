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

jail_name=$1

if zfs list -t snapshot "$JAIL_ZDIR/$jail_name@OLD" >/dev/null 2>&1; then
    zfs destroy -r "$JAIL_ZDIR/$jail_name@OLD"
fi

if zfs list -t snapshot "$JAIL_ZDIR/$jail_name@LATEST" >/dev/null 2>&1; then
    zfs rename -r "$JAIL_ZDIR/$jail_name@LATEST" "@OLD"
fi

if zfs list -t snapshot "$JAIL_ZDIR/$jail_name@PRE-UPDATE" >/dev/null 2>&1; then
    zfs rename -r "$JAIL_ZDIR/$jail_name@PRE-UPDATE" "@LATEST"
fi

zfs snapshot -r "$JAIL_ZDIR/$jail_name@PRE-UPDATE"

if zfs list -t snapshot "$JAIL_ZDIR/$jail_name@PRE-UPDATE" >/dev/null 2>&1; then
    echo "Snapshot created: $JAIL_ZDIR/$jail_name@PRE-UPDATE"
fi