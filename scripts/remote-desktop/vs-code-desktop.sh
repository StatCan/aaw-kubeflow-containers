#!/bin/sh

# Stops script execution if a command has an error
set -e

SHA256=c5d1cba85d23a0c96c4d97f89432598c143888e0005a2962fbd1b6be75d74ca4
VERSION=1.74.3

if [ ! -f "/resources/code/code" ]; then
    echo "Installing VS Code. Please wait..."
    cd $RESOURCES_PATH
    wget -q https://update.code.visualstudio.com/${VERSION}/linux-x64/stable -O ./vscode.tar.gz
    echo "${SHA256} ./vscode.tar.gz" | sha256sum -c -
    apt-get update
    tar -xf ./vscode.tar.gz --no-same-owner
    mv VSCode-linux-x64 code
    mkdir code/data
    mkdir code/data/extensions
    mkdir code/data/user-data
    rm ./vscode.tar.gz
else
    echo "VS Code is already installed"
fi
