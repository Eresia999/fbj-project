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

jail_name="$1"
jail_conf_file="$JAIL_CONF_DIR/$jail_name.conf"
jail_id="$2"
bridges="$3"

if [ -z "$bridges" ]; then
    bridges="$DEFAULT_BRIDGE"
fi

cat << EOF > $jail_conf_file
$jail_name {
    # STARTUP/LOGGING
    exec.start = "/bin/sh /etc/rc";
    exec.stop  = "/bin/sh /etc/rc.shutdown";
    exec.consolelog = "/var/log/jail_console_\${name}.log";

    # PERMISSIONS
    exec.clean;
    mount.devfs;
    allow.mount;
    devfs_ruleset = "5";
#    mount.fstab = $JAIL_DIR/\${name}/fstab;

    # PATH/HOSTNAME
    path = "$JAIL_DIR/\${name}/root";
    host.hostname = "\${name}";

    # VNET/VIMAGE
    vnet;
EOF

i="0"
for bridge in $bridges; do
    if [ "$i" -eq 0 ]; then
        printf "    vnet.interface = \"e${i}b_\${name}\";" >> "$jail_conf_file"
        i=$((i + 1))
    else
        printf "    vnet.interface += \"e${i}b_\${name}\";" >> "$jail_conf_file"
        i=$((i + 1))
    fi
done

printf "\n" >> "$jail_conf_file"

i="0"
for bridge in $bridges; do
    cat << EOF >> "$jail_conf_file"
    \$id_${i}="${jail_id}";
    \$bridge_${i}="${bridge}";
EOF
    jail_id=$((jail_id + 100))
    i=$((i + 1))
done

printf "\n" >> "$jail_conf_file"

i="0"
for bridge in $bridges; do
    printf "    exec.prestart += \"ifconfig epair\${id_${i}} create name e${i}a_\${name} up\";" >> "$jail_conf_file"
    printf "    exec.prestart += \"ifconfig epair\${id_${i}}b name e${i}b_\${name}\";" >> "$jail_conf_file"
    printf "    exec.prestart += \"ifconfig \${bridge_${i}} addm e${i}a_\${name}\";" >> "$jail_conf_file"
    i=$((i + 1))
done

printf "\n" >> "$jail_conf_file"

i="0"
for bridge in $bridges; do
    printf "    exec.poststop += \"ifconfig \${bridge_${i}} deletem e${i}a_\${name}\";" >> "$jail_conf_file"
    printf "    exec.poststop += \"ifconfig e${i}a_\${name} destroy\";" >> "$jail_conf_file"
    i=$((i + 1))
done

printf "}" >> "$jail_conf_file"