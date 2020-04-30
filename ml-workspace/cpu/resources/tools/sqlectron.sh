#!/bin/sh

# Stops script execution if a command has an error
set -e

if ! hash sqlectron 2>/dev/null; then
    cd /resources
    echo "Installing Sqlectron Term. Please wait..."
    npm install -g sqlectron-term
    echo "Installing Sqlectron GUI"
    wget https://github.com/sqlectron/sqlectron-gui/releases/download/v1.30.0/Sqlectron_1.30.0_amd64.deb -O ./sqlectron.deb
    apt-get update
    apt-get install -y ./sqlectron.deb
    rm ./sqlectron.deb
fi