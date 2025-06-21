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

jail_name="$1"
jail_ip="$2"
i="0"
first_ip=$(echo "$jail_ip" | awk '{print $1}')
jail_path="$JAIL_DIR/$jail_name/root"
nameserver_file="$jail_path/etc/resolv.conf"
rc_file="$jail_path/etc/rc.conf"

if [ -n "$jail_ip" ]; then
    ip=$(echo $first_ip | cut -d'/' -f1)
    netmask=$(echo $first_ip | cut -d'/' -f2)
    jail_gw=$(sh $JAIL_FIRST_IP "$ip" "$netmask")
fi

for ip in $jail_ip; do
    cat << EOF >> $rc_file
ifconfig_e${i}b_${jail_name}="inet $ip"
EOF
    i=$((i + 1))
done

echo "defaultrouter=\"$jail_gw\"" >> $rc_file

# Configure nameserver
sh $JAIL_NAMESERVER "$nameserver_file" "$jail_gw"