#!/bin/sh

# Stops script execution if a command has an error
set -e

if ! hash tilix 2>/dev/null; then
    echo "Installing Tilix Terminal. Please wait..."
    add-apt-repository ppa:webupd8team/terminix --yes
    apt-get update
    apt-get install tilix --yes
else
    echo "Tilix Terminal is already installed"
fi