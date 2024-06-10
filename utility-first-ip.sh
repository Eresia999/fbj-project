#!/bin/sh

ip="$1"
netmask_length="$2"

# Calcola il numero di bit per l'host
host_bits=$(expr 32 - $netmask_length)

# Converte l'IP in formato binario
IFS='.' read i1 i2 i3 i4 <<- EOF
    $ip
EOF
ip_binary=$(printf "%08d%08d%08d%08d" $(echo "ibase=10; obase=2; $i1" | bc) $(echo "ibase=10; obase=2; $i2" | bc) $(echo "ibase=10; obase=2; $i3" | bc) $(echo "ibase=10; obase=2; $i4" | bc))

# Estrai il segmento di rete
network_segment=$(echo "$ip_binary" | cut -c 1-$((32 - host_bits)))

# Calcola l'IP di rete in formato binario
network_ip_binary="${network_segment}$(printf '%0.s0' $(seq 1 $host_bits))"

# Aggiungi 1 all'IP di rete binario per ottenere il primo IP utilizzabile
first_usable_ip_binary=$(echo "obase=2; ibase=2; $network_ip_binary + 1" | bc)

# Completa l'IP binario fino a 32 bit
first_usable_ip_binary=$(printf "%032s" $first_usable_ip_binary)

# Converti il primo IP utilizzabile in formato decimale
first_usable_ip_dec=""
i=1
while [ $i -le 32 ]; do
    subnet_octet=$(echo "$first_usable_ip_binary" | cut -c $i-$((i + 7)))
    subnet_dec=$(echo "obase=10; ibase=2; $subnet_octet" | bc)
    first_usable_ip_dec="$first_usable_ip_dec$subnet_dec"
    if [ $i -lt 24 ]; then
        first_usable_ip_dec="${first_usable_ip_dec}."
    fi
    i=$(expr $i + 8)
done

echo "$first_usable_ip_dec"