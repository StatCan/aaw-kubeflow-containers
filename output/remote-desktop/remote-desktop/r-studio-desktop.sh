#!/bin/sh

# Stops script execution if a command has an error
set -e

VERSION=2023.06.0-421
RELEASE=jammy
SHA256=c5e551fcdda40dab3524a7568abdbdd1e4497e7324d06a620e5daf326a6e0970

if ! hash rstudio 2>/dev/null; then
    echo "Installing RStudio Desktop. Please wait..."
    cd $RESOURCES_PATH
    apt-get update
    #apt-get install --yes r-base
    wget https://s3.amazonaws.com/rstudio-ide-build/electron/${RELEASE}/amd64/rstudio-${VERSION}-amd64.deb -O ./rstudio.deb
    echo "${SHA256} ./rstudio.deb" | sha256sum -c -
    # ld library path makes problems
    LD_LIBRARY_PATH="" gdebi --non-interactive ./rstudio.deb
    rm ./rstudio.deb

else
    echo "RStudio is already installed"
fi
