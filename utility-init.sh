#!/bin/sh

# Includi il file di configurazione
CONFIG_FILE_USER="/usr/local/etc/fbj/fbj.conf"
CONFIG_FILE_SYSTEM="/usr/local/etc/fbj/fbj-system.conf"
if [ -f "$CONFIG_FILE_USER" ] && [ -f "$CONFIG_FILE_SYSTEM" ]; then
    . "$CONFIG_FILE_USER"
    . "$CONFIG_FILE_SYSTEM"
else
    echo "Configuration file not found"
    exit 1
fi

sysrc jail_enable="YES"
sysrc jail_list+=""

echo '.include "/etc/jail.conf.d/*.conf";' >> /etc/jail.conf

if [ -n $CUSTOM_DEVFS_RULES ]; then
    cp "$CUSTOM_DEVFS_RULES" /etc/devfs.rules
    service devfs restart
fi

if [ -z "$JAIL_ZMOUNTPOINT" ] || [ -z "$JAIL_MOUNTPOINT" ] || [ -z "$JAIL_ZMEDIA" ] || [ -z "$JAIL_ZDIR" ]; then
    echo "Errore: Alcune variabili non sono definite correttamente."
    exit 1
fi

if ! zfs list "$JAIL_ZMOUNTPOINT" >/dev/null 2>&1; then
    zfs create -o mountpoint="$JAIL_MOUNTPOINT" "$JAIL_ZMOUNTPOINT"
fi

if ! zfs list "$JAIL_ZMEDIA" >/dev/null 2>&1; then
    zfs create "$JAIL_ZMEDIA"
fi

if ! zfs list "$JAIL_ZDIR" >/dev/null 2>&1; then
    zfs create "$JAIL_ZDIR"
fi