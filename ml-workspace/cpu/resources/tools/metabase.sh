#!/bin/sh

# Stops script execution if a command has an error
set -e

INSTALL_ONLY=0
PORT=""
# Loop through arguments and process them: https://pretzelhands.com/posts/command-line-flags
for arg in "$@"; do
    case $arg in
        -i|--install) INSTALL_ONLY=1 ; shift ;;
        -p=*|--port=*) PORT="${arg#*=}" ; shift ;; # TODO Does not allow --port 1234
        *) break ;;
    esac
done

if [ ! -f "$RESOURCES_PATH/metabase.jar" ]; then
    cd $RESOURCES_PATH
    echo "Installing Metabase. Please wait..."
    wget http://downloads.metabase.com/v0.34.1/metabase.jar
else
    echo "Metabase is already installed"
fi
