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

# Verifica che sia stato fornito un nome per il jail come argomento
if [ -z "$1" ]; then
    echo "Usage: $0 delete <jail_name>"
    exit 1
fi

jail_name="$1"

printf "Destroying jail: %s\n" "$jail_name"

# Stop the jail
sh $JAIL_BOOT stop "$jail_name"

# Remove flags
chflags -R 0 "$JAIL_DIR/$jail_name"

if zfs list "$JAIL_ZDIR/$jail_name" >/dev/null 2>&1; then
  zfs destroy -r "$JAIL_ZDIR/$jail_name"
  if zfs list "$JAIL_ZDIR/$jail_name" >/dev/null 2>&1; then
    echo "Failed to delete ZFS dataset: $JAIL_ZDIR/$jail_name"
    exit 1
  else
    printf "Deleted ZFS dataset: %s\n" "$JAIL_ZDIR/$jail_name"
  fi
else
  if [ -d "$JAIL_DIR/$jail_name" ]; then
    rm -rf "$JAIL_DIR/$jail_name"
    if [ -d "$JAIL_DIR/$jail_name" ]; then
      echo "Failed to delete directory: $JAIL_DIR/$jail_name"
      exit 1
    else
      printf "Deleted directory: %s\n" "$JAIL_DIR/$jail_name"
    fi
  else
    printf "Directory not found: %s\n" "$JAIL_DIR/$jail_name"
  fi
fi

# Remove jail.conf
rm $JAIL_CONF_DIR/$jail_name.conf

# Remove the jail from rc.conf list
sysrc jail_list-=$jail_name