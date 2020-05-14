#!/bin/sh

# Stops script execution if a command has an error
set -e

if [ ! -f "/opt/Hyper/hyper" ]; then
    echo "Installing Hyper Terminal. Please wait..."
    cd $RESOURCES_PATH
    apt-get update
    apt-get install -y libappindicator1 gconf2 gconf-service
    wget https://releases.hyper.is/download/deb -O ./hyper.deb
    apt-get install -y ./hyper.deb
    rm ./hyper.deb
else
    echo "Hyper Terminal is already installed"
fi
