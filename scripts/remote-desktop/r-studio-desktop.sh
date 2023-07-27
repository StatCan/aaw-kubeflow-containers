#!/bin/sh

# Stops script execution if a command has an error
set -e

VERSION=2023.06.1-524
RELEASE=jammy
SHA256=c030ec8338f1c76b3ae27997ec4411a0af43b2367dedb3d48e95c319b5425698

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
