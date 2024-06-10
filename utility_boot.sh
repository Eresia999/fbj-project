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
        echo -e "\n\tDisattivo $jail_name"
        service jail stop "$jail_name"
  
        # Ciclo while per confermare che la jail sia spenta
        while [ "$(jls -N | awk '{print $1}' | grep -c "$jail_name")" -eq 1 ]; do
            echo -e "\n\tAttendere: la jail $jail_name sta ancora spegnendo..."
            sleep 1
        done
  
        echo -e "\n\tLa jail $jail_name è stata spenta con successo."
    else
        echo -e "\n\tLa jail $jail_name non è attiva."
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
        echo "No option found"
        ;;
esac