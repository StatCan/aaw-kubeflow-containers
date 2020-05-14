#!/bin/sh

# Stops script execution if a command has an error
set -e

if ! hash emacs 2>/dev/null; then
    echo "Installing Emacs. Please wait..."
    apt-get update
    LD_LIBRARY_PATH="" LD_PRELOAD="" apt-get install --yes emacs
else
    echo "Emacs is already installed"
fi