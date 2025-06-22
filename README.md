# fbj-project
 
Script to create and manage VNET jails as described in the FreeBSD Handbook.
I was just too lazy to do it manually.

You must install it as root, the paths will be:

    - Main script: /usr/local/bin

    - Other data: /usr/local/share/fbj

    - Config file: /usr/local/etc/fbj

Jails are created exactly as described in the Handbook.

> [!NOTE]  
>If you need a bridge (and you will), you must configure it manually.

---

## Installation

```sh 
git clone https://github.com/Eresia999/fbj-project.git
cd fbj-project
sudo ./install.sh
sudo fbj init 
```

## Commands

`fbj [create|update|upgrade|delete|rename|start|stop|restart|autostart|init]`

### Create a new jail:

`fbj create <name> <ip1> <bridge1> [<ip2> <bridge2>] [start] [autostart]`

- ip1 and bridge1 are mandatory.
- ip2 and bridge2 are optional (for dual-stack).
- Add start to start the jail after creation.
- Add autostart to start the jail at boot.

## Other commands:
```sh
fbj update <name> [<base>|<pkg>]        # Update base or packages
fbj upgrade <name> <RELEASE>            # Upgrade jail to new FreeBSD release
fbj delete <name>                       # Delete a jail
fbj rename <name> <newname>             # Rename a jail
fbj start|stop|restart|autostart <name> # Start, stop, restart or start a jail at boot
fbj init                                # Initialize base system for jail creation 
```