#!/bin/sh

# Stops script execution if a command has an error
set -e

if ! hash robo3t 2>/dev/null; then
    echo "Installing Robo3T. Please wait..."
    cd $RESOURCES_PATH
    wget https://github.com/Studio3T/robomongo/releases/download/v1.3.1/robo3t-1.3.1-linux-x86_64-7419c406.tar.gz -O ./robomongo.tar.gz
    tar xfz ./robomongo.tar.gz
    chmod a+rwx ./robo3t-1.3.1-linux-x86_64-7419c406/bin/robo3t
    ln -s $RESOURCES_PATH/robo3t-1.3.1-linux-x86_64-7419c406/bin/robo3t /usr/local/bin/robo3t 
    rm ./robomongo.tar.gz
else
    echo "Robo3T is already installed"
fi