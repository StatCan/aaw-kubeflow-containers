#!/bin/sh

# Stops script execution if a command has an error
set -e

if ! hash nteract 2>/dev/null; then
    echo "Installing Nteract. Please wait..."
    cd $RESOURCES_PATH
    wget https://github.com/nteract/nteract/releases/download/v0.15.0/nteract_0.15.0_amd64.deb -O ./nteract.deb
    apt-get update
    apt-get install -y ./nteract.deb
    rm ./nteract.deb
else
    echo "Nteract is already installed"
fi