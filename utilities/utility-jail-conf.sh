#!/bin/sh

# Include the configuration file

CONFIG_DIR="/usr/local/etc/fbj"

CONFIG_FILE_USER="$CONFIG_DIR/fbj.conf"
CONFIG_FILE_SYSTEM="$CONFIG_DIR/fbj-system.conf"

if [ -f "$CONFIG_FILE_USER" ] && [ -f "$CONFIG_FILE_SYSTEM" ]; then
    . "$CONFIG_FILE_USER"
    . "$CONFIG_FILE_SYSTEM"
else
    printf "Configuration file not found\n"
    exit 1
fi

jail_name="$1"
jail_conf_file="$JAIL_CONF_DIR/$jail_name.conf"
jail_id="$2"
bridges="$3"
template="$CONFIG_DIR/templates/$4"

sed \
    -e "/# --- DO NOT EDIT BELOW ---/q" \
    -e "s|\$jail_name|$jail_name|g" \
    -e "s|\$JAIL_DIR|$JAIL_DIR|g" \
    "$template" > "$jail_conf_file"

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
    printf "    exec.prestart += \"ifconfig epair\${id_${i}} create name e${i}a_\${name} up\";\n" >> "$jail_conf_file"
    printf "    exec.prestart += \"ifconfig epair\${id_${i}}b name e${i}b_\${name}\";\n" >> "$jail_conf_file"
    printf "    exec.prestart += \"ifconfig \${bridge_${i}} addm e${i}a_\${name}\";\n" >> "$jail_conf_file"
    i=$((i + 1))
done

printf "\n" >> "$jail_conf_file"

i="0"
for bridge in $bridges; do
    printf "    exec.poststop += \"ifconfig \${bridge_${i}} deletem e${i}a_\${name}\";\n" >> "$jail_conf_file"
    printf "    exec.poststop += \"ifconfig e${i}a_\${name} destroy\";\n" >> "$jail_conf_file"
    i=$((i + 1))
done

printf "}" >> "$jail_conf_file"