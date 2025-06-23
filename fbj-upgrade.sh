#!/bin/sh

# Include the configuration file
. ./conf/fbj-system.conf

# update scripts and utilities
cp fbj "$MAIN_SCRIPT_DIR"/
cp -r scripts "$FBJ_DIR"/
cp -r utility "$FBJ_DIR"/
cp fbj-system.conf "$CONFIG_DIR"/

echo "Upgrade complete"