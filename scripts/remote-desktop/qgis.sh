#!/bin/bash
# Stops script execution if a command has an error
set -e

if ! hash qgis 2>/dev/null; then
  apt-get update
  apt-get install -y gnupg software-properties-common
  #Removed tools here, need to put back
  cat $RESOURCES_PATH/qgis-2020.gpg.key | gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/qgis-archive.gpg --import
  chmod a+r /etc/apt/trusted.gpg.d/qgis-archive.gpg
  add-apt-repository "deb https://qgis.org/debian `lsb_release -c -s` main"
  apt-get update
  apt-get install -y qgis qgis-plugin-grass


else
    echo "QGIS is already installed"
fi

echo "QGIS and supporting libraries have been installed."
