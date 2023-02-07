#!/bin/sh

# Stops script execution if a command has an error
set -e

SHA256=0e84eedab8b1fca67597c03303185504d40da93b4953d73c7f4ef8a8df8e3eb8
VERSION=1.74.3

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
