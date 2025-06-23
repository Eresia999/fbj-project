#!/bin/sh

dir="$1"
i=0
found="false"

while [ "$found" = false ]; do
    # Crea la stringa da cercare nel formato $id="valorenumerico";
    string="\ \ \$id_0=\"$i\";"

    # Controlla se la stringa da cercare esiste nei file nella directory
    if grep -q "$string" $dir/*; then
        i=$((i + 1))
    else
        found=true
    fi
done

echo "$i"