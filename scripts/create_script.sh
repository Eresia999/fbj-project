#!/bin/sh

# Include the configuration file

FBJ_DIR="/usr/local/etc/fbj"

CONFIG_FILE_USER="$FBJ_DIR/fbj.conf"
CONFIG_FILE_SYSTEM="$FBJ_DIR/fbj-system.conf"

if [ -f "$CONFIG_FILE_USER" ] && [ -f "$CONFIG_FILE_SYSTEM" ]; then
    . "$CONFIG_FILE_USER"
    . "$CONFIG_FILE_SYSTEM"
else
    printf "Configuration file not found"
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
        release="$(freebsd-version | cut -d- -f1-2)"
    fi

    printf "\n\tCreating %s...\n" "$jail_name"

    # Verify if base exists
    if [ ! -e "$MEDIA_DIR/$release-base.txz" ]; then
        fetch "https://download.freebsd.org/ftp/releases/$hw/$arch/$release/base.txz" -o "$MEDIA_DIR/$release-base.txz"
    fi

    # Creating dataset
    zfs create "$zfs_path"
    mkdir -p "$jail_path"

    # Creating jail
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
template="default.template"
jail_id="0"
jail_path="$JAIL_DIR/$jail_name/root"

# Verify if dataset exists
if zfs list "$JAIL_ZDIR/$jail_name" >/dev/null 2>&1; then
  printf "Error: Dataset already exist."
  exit 1
fi

# Check autostart and start now
for arg in "$@"; do
    case "$arg" in
    10.* | 172.* | 192.168.*)
        ip_part=$(printf "%s" "$arg" | cut -d/ -f1)
        cidr_part=$(printf "%s" "$arg" | cut -d/ -f2)

        # Missing or wrong CIDR part
        while true; do
            case "$cidr_part" in
                ''|*[!0-9]*)
                    cidr_part=""
                    ;;
                *)
                    if [ "$cidr_part" -ge 8 ] && [ "$cidr_part" -le 32 ]; then
                        break  # valid
                    fi
                    ;;
            esac

            printf "Netmask CIDR invalid or missing for %s. Insert value between 8 and 32 (or 0 to abort): " "$ip_part"
            read cidr_part

            if [ "$cidr_part" = 0 ]; then
                echo "Aborting jail creation."
                exit 1
            fi
        done

        arg="${ip_part}/${cidr_part}"

        ip="${ip} ${arg}"
        ;;
    *bridge*)
        bridges="${bridges} ${arg}"
        ;;
    autostart | start)
        boot_conf="${boot_conf} ${arg}"
        ;;
    *template)
        template="${arg}"
        ;;
    *RELEASE)
        release="${arg}"
        ;;
    *)
        if [ "$arg" != "$jail_name" ]; then
            printf "Wrong value for: %s" "$arg"
        fi
    ;;
    esac
    
done

# Check jail name
if [ -f "$JAIL_CONF_DIR/$jail_name.conf" ] || jls name | grep -q "^$jail_name$"; then
    printf "Jail %s already exists./n" "$jail_name"
    exit 1
fi

# Check ip(s)
if [ -z "$ip" ]; then
    printf "Error: No IP address provided. Please provide at least one IP address.\n"
    exit 1
fi

# Check bridge(s)
set -- $ip
count_ip=$#
set -- $bridges
count_bridges=$#

if [ "$count_ip" -gt "$count_bridges" ]; then
    diff=$(( count_ip - count_bridges ))
    if [ "$diff" -gt 1 ]; then
        printf "Error: %d IPs (%s) and %d bridges (%s). Please check your arguments.\n" "$count_ip" "$ip" "$count_bridges" "$bridges"
        exit 1
    fi
    bridges="$DEFAULT_BRIDGE $bridges"
fi

# Check template
if [ ! -f "$CONFIG_DIR"/"$template" ]; then
    printf "Error: template %s not found in %s\n" "$template" "$CONFIG_DIR"
    exit 1
fi

# Create jail
create_jail "$jail_name" "$jail_path" "$release"

# Create jail ID
if [ -n "$(find "$JAIL_CONF_DIR" -type f)" ]; then
    jail_id=$(sh $JAIL_UNIQUE_ID "$JAIL_CONF_DIR")
fi
    
# Config jail.conf
sh $JAIL_CONF "$jail_name" "$jail_id" "$bridges" "$template"

# Config Network
sh $JAIL_NETWORK "$jail_name" "$ip"

# Config Boot
if [ -n "$boot_conf" ]; then
    for arg in $boot_conf; do
        sh $JAIL_BOOT "$arg" "$jail_name"
    done
fi

printf "New jail: %s\n" "$jail_name"