#!/bin/sh

# Include the configuration file
. ./conf/fbj-system.conf

# if not root...
if [ "$(id -u)" -ne 0 ]; then
    printf "\nPlease run this script as root to install fbj\n"
    exit 1
fi

# update scripts and utilities
cp fbj "$MAIN_SCRIPT_DIR"/
cp -r scripts "$FBJ_DIR"/
cp -r utilities "$FBJ_DIR"/
cp -r conf/templates "$CONFIG_DIR"/
printf "\nUpgrade complete\n"