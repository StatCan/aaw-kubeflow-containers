#!/bin/sh

# Stops script execution if a command has an error
set -e

if ! hash alacritty 2>/dev/null; then
    echo "Installing Alacritty Terminal. Please wait..."
    add-apt-repository ppa:mmstick76/alacritty
    apt-get update
    apt-get install -y alacritty
else
    echo "Alacritty Terminal is already installed"
fi