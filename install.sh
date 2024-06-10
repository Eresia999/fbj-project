#!/bin/sh

# Includi il file di configurazione
. ./fbj.conf

# Funzione per creare una directory se non esiste
create_directory() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
    fi
}

# Verifica che lo script sia eseguito con i privilegi di root
if [ "$(id -u)" -ne 0 ]; then
    echo "Questo script deve essere eseguito con i privilegi di root."
    exit 1
fi

create_directory "$MAIN_SCRIPT_DIR"
create_directory "$SCRIPTS_DIR"
create_directory "$UTILITIES_DIR"
create_directory "$CONFIG_DIR"
create_directory "$MEDIA_DIR"

# Copia gli script principali
cp fbj "$MAIN_SCRIPT_DIR/"
cp *.conf "$CONFIG_DIR/"
cp *script.sh "$SCRIPTS_DIR/"
cp utility* "$UTILITIES_DIR/"

chmod +x "$MAIN_SCRIPT_DIR/fbj"
chmod +x "$SCRIPTS_DIR"/*.sh
chmod +x "$UTILITIES_DIR"/utility*

echo "Installazione completata con successo!"
