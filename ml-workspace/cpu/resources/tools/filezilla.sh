#!/bin/sh

# Stops script execution if a command has an error
set -e

if ! hash filezilla 2>/dev/null; then
    echo "Installing Filezilla. Please wait..."
    apt-get update
    apt-get install --yes filezilla
else
    echo "Filezilla is already installed"
fi