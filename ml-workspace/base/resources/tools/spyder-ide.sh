#!/bin/sh

# Stops script execution if a command has an error
set -e

if ! hash spyder 2>/dev/null; then
    echo "Installing Spyder. Please wait..."
    conda install -y spyder
else
    echo "Spyder is already installed"
fi