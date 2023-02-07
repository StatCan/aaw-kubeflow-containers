#!/bin/sh

# Stops script execution if a command has an error
set -e

VERSION=1.3.1093
RELEASE=bionic
SHA256=ff222177fa968f8cf82016e2086bab10ca4bcbe02a4c16f0ecb650151748cf1c

if ! hash rstudio 2>/dev/null; then
    echo "Installing RStudio Desktop. Please wait..."
    cd $RESOURCES_PATH
    apt-get update
    #apt-get install --yes r-base
    wget https://download1.rstudio.org/desktop/${RELEASE}/amd64/rstudio-${VERSION}-amd64.deb -O ./rstudio.deb
    echo "${SHA256} ./rstudio.deb" | sha256sum -c -
    # ld library path makes problems
    LD_LIBRARY_PATH="" gdebi --non-interactive ./rstudio.deb
    rm ./rstudio.deb

else
    echo "RStudio is already installed"
fi
