#!/bin/sh

# Stops script execution if a command has an error
set -e

SHA256=9ba14d46cdb156b415e129c25a3d2eae6f7208914ee3633d33e2f2a2f1d8ec77
VERSION=1.82.2

if [ ! -f "/usr/share/code/code" ]; then
    echo "Installing VS Code. Please wait..."
    cd $RESOURCES_PATH
    wget -q https://update.code.visualstudio.com/${VERSION}/linux-deb-x64/stable -O ./vscode.deb
    echo "${SHA256} ./vscode.deb" | sha256sum -c -
    apt-get update
    apt-get install -y ./vscode.deb
    rm ./vscode.deb
    rm /etc/apt/sources.list.d/vscode.list
else
    echo "VS Code is already installed"
fi
