#!/bin/sh

# Stops script execution if a command has an error
set -e

if ! hash gitkraken 2>/dev/null; then
    cd $RESOURCES_PATH
    echo "Installing Git Kraken. Please wait..."
    apt-get update
    wget https://release.gitkraken.com/linux/gitkraken-amd64.deb -O ./gitkraken.deb
    apt-get install --yes gvfs-bin gconf2
    apt-get install -y ./gitkraken.deb
    rm ./gitkraken.deb
    apt-get clean
else
    echo "Git Kraken is already installed"
fi