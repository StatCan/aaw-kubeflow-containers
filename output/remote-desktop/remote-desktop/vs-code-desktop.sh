#!/bin/sh

# Stops script execution if a command has an error
set -e

SHA256=4203ec7e216841ea97aedc4c77ae9973b7aa827734eb03fb165108cbb2cf11c1
VERSION=1.74.3

if [ ! -f "/resources/code/code" ]; then
    echo "Installing VS Code. Please wait..."
    cd $RESOURCES_PATH
    wget -q https://update.code.visualstudio.com/${VERSION}/linux-x64/stable -O ./vscode.tar.gz
    echo "${SHA256} ./vscode.tar.gz" | sha256sum -c -
    tar -xf ./vscode.tar.gz --no-same-owner
    mv VSCode-linux-x64 code
    mkdir code/data
    mkdir code/data/extensions
    mkdir code/data/user-data
    rm ./vscode.tar.gz
else
    echo "VS Code is already installed"
fi
