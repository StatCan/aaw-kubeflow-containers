#!/bin/sh

# Stops script execution if a command has an error
set -e

SHA256=4203ec7e216841ea97aedc4c77ae9973b7aa827734eb03fb165108cbb2cf11c1
VERSION=1.76.2

if [ ! -f "/usr/share/VSCode-linux-x64/code" ]; then
    echo "Installing VS Code. Please wait..."
    cd /usr/share
    wget -q https://update.code.visualstudio.com/${VERSION}/linux-x64/stable -O ./vscode.tar.gz
    echo "${SHA256} ./vscode.tar.gz" | sha256sum -c -
    tar -xzf ./vscode.tar.gz
    mkdir VSCode-linux-x64/data
    mkdir VSCode-linux-x64/data/extensions
    mkdir VSCode-linux-x64/data/user-data
    rm ./vscode.tar.gz
else
    echo "VS Code is already installed"
fi
