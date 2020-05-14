#!/bin/sh

# Stops script execution if a command has an error
set -e

if [ ! -f "/opt/Rodeo/rodeo" ]; then
    echo "Installing Rodeo. Please wait..."
    cd $RESOURCES_PATH
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 33D40BC6
    add-apt-repository -u "deb http://rodeo-deb.yhat.com/ rodeo main"
    apt-get update
    apt-get -y install libgconf2-4
    apt-get -y --allow-unauthenticated install rodeo
else
    echo "Rodeo is already installed"
fi