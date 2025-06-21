#!/bin/sh

# Include the configuration file

FBJ_DIR="/usr/local/etc/fbj"

if [ -d "$HOME/.local/share/fbj" ]; then
    FBJ_DIR="$HOME/.local/share/fbj"
fi

CONFIG_FILE_USER="$FBJ_DIR/fbj.conf"
CONFIG_FILE_SYSTEM="$FBJ_DIR/fbj-system.conf"

if [ -f "$CONFIG_FILE_USER" ] && [ -f "$CONFIG_FILE_SYSTEM" ]; then
    . "$CONFIG_FILE_USER"
    . "$CONFIG_FILE_SYSTEM"
else
    echo "Configuration file not found"
    exit 1
fi

# Funzione per aggiornare una jail
update_jail() {
    jail_name="$1"
    option="$2"
    started=1

    # Start jail if stopped
    if [ ! "$(jls -N | awk '{print $1}' | grep -c "$jail_name")" -eq 1 ]; then
        echo "Starting: $jail_name"
        sh $JAIL_BOOT start "$jail_name"

        # Wait for connection
        #echo "Wait for connection"
        #jexec -l $jail_name ping -o 1.1.1.1
        
        started=0
        echo "Started: $jail_name"
    fi

    # Finally update the jail

    if [ "$option" != "pkg" ]; then
        freebsd-update -j "$jail_name" fetch install
    fi

    if [ "$option" != "base" ]; then
        pkg -j "$jail_name" update
        pkg -j "$jail_name" upgrade
    fi

    if [ "$started" -eq 0 ]; then
        echo -e "Stopping: $jail_name..."
        sh $JAIL_BOOT stop "$jail_name"
    else
        sh $JAIL_BOOT restart "$jail_name"
    fi
}

# Main

jail_name="$1"
option="$2"

if [ "$1" = "pkg" ] || [ "$1" = "base" ]; then
    option="$1"
    jail_name=""
fi

if [ -z "$jail_name" ]; then
    for file in "$JAIL_CONF_DIR"/*.conf; do
        jail_name=$(basename "$file" .conf)
        echo -e "\n\tUpdating: $jail_name\n"
        sh $BACKUP_JAIL "$jail_name"
        update_jail "$jail_name" "$option"
    done  
else
    sh $BACKUP_JAIL "$jail_name"
    update_jail "$jail_name" "$option"
fi