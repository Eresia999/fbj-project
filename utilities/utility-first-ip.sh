#!/bin/sh

# Funzione per convertire un IP decimale in intero a 32 bit
ip_to_int() {
    local ip="$1"
    local a b c d
    IFS=. read -r a b c d <<-EOF
    $ip
EOF
    echo "$(( (a << 24) + (b << 16) + (c << 8) + d ))"
}

# Funzione per convertire un intero a 32 bit in IP decimale
int_to_ip() {
    local ip_int="$1"
    echo "$(( (ip_int >> 24) & 0xFF )).$(( (ip_int >> 16) & 0xFF )).$(( (ip_int >> 8) & 0xFF )).$(( ip_int & 0xFF ))"
}

# Calcola il primo IP utilizzabile
ip="$1"
netmask_length="$2"

# Converti IP in intero
ip_int=$(ip_to_int "$ip")

# Calcola la netmask e l'IP di rete
netmask_int=$(( 0xFFFFFFFF << (32 - netmask_length) ))
network_int=$(( ip_int & netmask_int ))

# Primo IP utilizzabile = IP di rete + 1
first_usable_int=$(( network_int + 1 ))

# Converti in formato IP
first_usable_ip=$(int_to_ip "$first_usable_int")

echo "$first_usable_ip"