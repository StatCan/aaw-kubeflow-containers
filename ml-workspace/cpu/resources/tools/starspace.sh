#!/bin/sh

# Stops script execution if a command has an error
set -e

if ! hash starspace 2>/dev/null; then
    cd $RESOURCES_PATH
    echo "Installing Boost. Please wait..."
    mkdir $RESOURCES_PATH/boost
    cd $RESOURCES_PATH/boost
    wget https://dl.bintray.com/boostorg/release/1.63.0/source/boost_1_63_0.zip
    unzip -q boost_1_63_0.zip 
    rm boost_1_63_0.zip
    mv boost_1_63_0 /usr/local/bin
    cd /usr/local/bin/boost_1_63_0
    echo "Installing Starspace"
    mkdir $RESOURCES_PATH/starspace
    cd $RESOURCES_PATH/starspace
    git clone https://github.com/facebookresearch/Starspace.git
    cd Starspace
    make
    chmod -R a+rwx $RESOURCES_PATH/starspace
    cp "starspace" /usr/local/bin
    # TODO remove starspace dir in resources? 
fi