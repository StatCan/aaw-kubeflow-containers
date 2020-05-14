#!/bin/sh

# Stops script execution if a command has an error
set -e

if ! hash beakerx 2>/dev/null; then
    echo "Installing BeakerX. Please wait..."
    pip install --no-cache-dir py4j beakerx 
    beakerx install
    jupyter labextension install beakerx-jupyterlab
else
    echo "BeakerX is already installed"
fi