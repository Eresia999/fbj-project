#!/bin/sh

# Include il file di configurazione se esiste
CONFIG_FILE_USER="/usr/local/etc/fbj/fbj.conf"
if [ -f "$CONFIG_FILE_USER" ]; then
    . "$CONFIG_FILE_USER"
else
    echo "Configuration file not found: $CONFIG_FILE_USER"
    echo "Install fbj: ./install.sh"
    exit 1
fi

# Funzione per creare una directory se non esiste
#create_directory() {
#    local dir="$1"
#    if [ ! -d "$dir" ]; then
#        mkdir -p "$dir"
#    fi
#}

# Verifica che lo script sia eseguito con i privilegi di root
if [ "$(id -u)" -ne 0 ]; then
    echo "Questo script deve essere eseguito con i privilegi di root."
    exit 1
fi

# Copia gli script principali
cp fbj "$MAIN_SCRIPT_DIR/"
cp *script.sh "$SCRIPTS_DIR/"
cp utility* "$UTILITIES_DIR/"
cp fbj-system.conf "$CONFIG_DIR/"

# Autorizza l'esecuzione
chmod +x "$MAIN_SCRIPT_DIR/fbj"
chmod +x "$SCRIPTS_DIR"/*.sh
chmod +x "$UTILITIES_DIR"/utility*

echo "Upgrade complete"