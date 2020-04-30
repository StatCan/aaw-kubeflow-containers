#!/bin/sh

# Stops script execution if a command has an error
set -e

if [ ! -f "/usr/share/azuredatastudio/azuredatastudio" ]; then
    echo "Installing Azure Data Studio. Please wait..."
    cd $RESOURCES_PATH
    wget https://go.microsoft.com/fwlink/?linkid=2092022 -O ./azure-data-studio.deb
    apt-get update
    apt-get install -y ./azure-data-studio.deb
    rm ./azure-data-studio.deb
else
    echo "Azure Data Studio is already installed"
fi