#!/bin/sh

# Stops script execution if a command has an error
set -e

if ! hash go 2>/dev/null; then
    echo "Installing Go Interpreter. Please wait..."
    apt-get update
    apt-get install -y golang-go
    # Set env variables?:
    # export GOROOT=/usr/local/go
    # export GOPATH=$HOME/go
    # export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
else
    echo "Go Interpreter is already installed"
fi

# Install vscode go extension 
if hash code 2>/dev/null; then
    # https://marketplace.visualstudio.com/items?itemName=ms-vscode.Go
    LD_LIBRARY_PATH="" LD_PRELOAD="" code --user-data-dir=$HOME/.config/Code/ --extensions-dir=$HOME/.vscode/extensions/ --install-extension ms-vscode.Go
else
    echo "Please install the desktop version of vscode via the vs-code-desktop.sh script to install go vscode extensions."
fi
