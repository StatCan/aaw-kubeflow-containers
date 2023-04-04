#!/bin/sh

# Stops script execution if a command has an error
set -e

SHA256=0e84eedab8b1fca67597c03303185504d40da93b4953d73c7f4ef8a8df8e3eb8
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
