#!/bin/sh

# Stops script execution if a command has an error
set -e

echo "Installing GUI Tool Collection. Please wait..."
apt-get update
LD_LIBRARY_PATH="" LD_PRELOAD="" apt-get install -y --no-install-recommends \
        gnome-tweak-tool \
        file-roller \
        gitg \
        mupdf \
        synapse \
        meld \
        ark \
        neovim \
        muon
