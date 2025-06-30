#!/bin/sh

option="$1"
jail_name="$2"

autostart() {
    sysrc jail_list+="$jail_name"
}

start_jail() {
    service jail start "$jail_name"
}

stop_jail() {
    if [ "$(jls -N | awk '{print $1}' | grep -c "$jail_name")" -eq 1 ]; then
        printf "\n\tShutting down %s\ns" "$jail_name"
        service jail stop "$jail_name"
  
        # Ciclo while per confermare che la jail sia spenta
        while [ "$(jls -N | awk '{print $1}' | grep -c "$jail_name")" -eq 1 ]; do
            printf "."
            sleep 1
        done
  
        printf "\n\t $jail_name stopped.\n"
    else
        printf "\n\t $jail_name is not started.\n"
    fi
}

restart_jail() {
    service jail restart $jail_name
}

case $option in
    autostart)
        autostart
        ;;
    start)
        start_jail
        ;;
    stop)
        stop_jail
        ;;
    restart)
        restart_jail
        ;;
    *)
        printf "Invalid option: %s\n" "$option"
        ;;
esac