#!/bin/sh

# Stops script execution if a command has an error
set -e

#Will want to update this version of VSCode
SHA256=6c117339d77b9593ad20b6eb4601ff7d0fd468922550d500edf07e3071e9a041
VERSION=1.46.0


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
