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

create_jail() {
    local jail_name="$1"
    local jail_path="$2"
    local release="$3"
    local zfs_path="$JAIL_ZDIR/$jail_name"
    local arch="$(uname -p)"
    local hw="$(uname -m)"

    if [ -z "$release" ]; then
        release="$(echo $(freebsd-version) | awk -F- '{print $1 "-" $2}')"
    fi

    echo -e "\n\tCreo jail $jail_name\n"

    # Verifica se MEDIA contiene la base 
    if [ ! -e "$MEDIA_DIR/$release-base.txz" ]; then
        fetch "https://download.freebsd.org/ftp/releases/$hw/$arch/$release/base.txz" -o "$MEDIA_DIR/$release-base.txz"
    fi

    # Creo i dataset
    zfs create "$zfs_path"
    mkdir -p "$jail_path"

    # Installo la jail
    tar -xf "$MEDIA_DIR/$release-base.txz" -C "$jail_path" --unlink
    cp /etc/localtime "$jail_path/etc/localtime"
    #bsdinstall jail "$jail_path"
    freebsd-update -b "$jail_path" fetch install
}

# Main
jail_name="$1"
ip=""
bridges=""
boot_conf=""
release=""
jail_id="0"
jail_path="$JAIL_DIR/$jail_name/root"

# Verifica se il dataset esiste
if zfs list "$JAIL_ZDIR/$jail_name" >/dev/null 2>&1; then
  echo "Error: Dataset already exist."
  exit 1
fi

# Check autostart and start now
for arg in "$@"; do
    case "$arg" in
    10.* | 172.* | 192.168.*)
        ip="${ip} ${arg}"
        ;;
    *bridge*)
        bridges="${bridges} ${arg}"
        ;;
    autostart | start)
        boot_conf="${boot_conf} ${arg}"
        ;;
    *RELEASE)
        release="${arg}"
        ;;
    *)
    ;;
    esac
    
done

# Creazione della jail
create_jail "$jail_name" "$jail_path" "$release"

# Create jail ID
if [ -n "$(find "$JAIL_CONF_DIR" -type f)" ]; then
    jail_id=$(sh $JAIL_UNIQUE_ID "$JAIL_CONF_DIR")
fi
    
# Config jail.conf
sh $JAIL_CONF "$jail_name" "$jail_id" "$bridges"

# Config Network
sh $JAIL_NETWORK "$jail_name" "$ip"

# Config Boot
if [ -n "$boot_conf" ]; then
    for arg in $boot_conf; do
        sh $JAIL_BOOT "$arg" "$jail_name"
    done
fi

echo "New jail: $jail_name"