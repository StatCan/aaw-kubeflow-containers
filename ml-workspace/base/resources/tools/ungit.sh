#!/bin/sh

# Stops script execution if a command has an error
set -e

if ! hash ungit 2>/dev/null; then
    echo "Installing Ungit. Please wait..."
    npm update
    npm install -g ungit@1.5.1
else
    echo "Ungit is already installed"
fi