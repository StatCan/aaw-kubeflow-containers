#!/bin/sh

# Stops script execution if a command has an error
set -e

VERSION=2023.06.0-421
RELEASE=jammy
SHA256=ae9dc07471a8a83f3f8b5c95b6ae77fdc456163a43915768f312e626dac3a6fc

if ! hash rstudio 2>/dev/null; then
    echo "Installing RStudio Desktop. Please wait..."
    cd $RESOURCES_PATH
    apt-get update
    #apt-get install --yes r-base
    wget https://download1.rstudio.org/electron/${RELEASE}/amd64/rstudio-${VERSION}-amd64.deb -O ./rstudio.deb
    echo "${SHA256} ./rstudio.deb" | sha256sum -c -
    # ld library path makes problems
    LD_LIBRARY_PATH="" gdebi --non-interactive ./rstudio.deb
    rm ./rstudio.deb

else
    echo "RStudio is already installed"
fi
