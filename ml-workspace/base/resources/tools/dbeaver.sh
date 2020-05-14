#!/bin/sh

# Stops script execution if a command has an error
set -e

if ! hash dbeaver 2>/dev/null; then
    echo "Installing DBeaver. Please wait..."
    add-apt-repository ppa:serge-rider/dbeaver-ce --yes
    apt-get update
    apt-get install dbeaver-ce --yes
else
    echo "DBeaver is already installed"
fi