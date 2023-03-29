#!/bin/sh

# Stops script execution if a command has an error
set -e

SHA256=e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
VERSION=1.76.2

if [ ! -f "/usr/share/code/code" ]; then
    echo "Installing VS Code. Please wait..."
    cd $HOME
    wget -q https://update.code.visualstudio.com/${VERSION}/linux-x64/stable -O ./vscode.tar.gz
    echo "${SHA256} ./vscode.tar.gz" | sha256sum -c -
    tar -xzf ./vscode.tar.gz
    cd vscode
    mkdir data
    rm ./vscode.tar.gz
    rm /etc/apt/sources.list.d/vscode.list
else
    echo "VS Code is already installed"
fi
