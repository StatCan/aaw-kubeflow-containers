#!/bin/sh

# Stops script execution if a command has an error
set -e

if ! hash atom 2>/dev/null; then
    echo "Installing Atom. Please wait..."
    add-apt-repository ppa:webupd8team/atom --yes
    apt-get update
    apt-get install atom --yes
    apt-get clean
else
    echo "Atom is already installed"
fi
