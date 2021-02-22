#!/bin/bash
# Stops script execution if a command has an error
#This is simply a test to see if another installation of qgis will resolve
set -e

#if ! hash qgis 2>/dev/null; then
#  apt-get update
#  apt-get install -y gnupg software-properties-common
  #Removed tools here, need to put back
#  cat $RESOURCES_PATH/qgis-2020.gpg.key | gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/qgis-archive.gpg --import
#  chmod a+r /etc/apt/trusted.gpg.d/qgis-archive.gpg
#  add-apt-repository "deb https://qgis.org/debian `lsb_release -c -s` main"
#  apt-get update
#  apt-get install -y qgis qgis-plugin-grass
  #I dont know if this apt-get install is the source of qgis not being recognized initially 
  # / needing the qgis.pth file 

#else
#    echo "QGIS is already installed"
#fi

#This follows exactly whats on: https://www.qgis.org/en/site/forusers/alldownloads.html#debian-ubuntu
#does adding 'sudo' do anything here? 
apt install -y gnupg software-properties-common
wget -qO - https://qgis.org/downloads/qgis-2020.gpg.key | gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/qgis-archive.gpg --import
chmod a+r /etc/apt/trusted.gpg.d/qgis-archive.gpg
add-apt-repository "deb https://qgis.org/debian `lsb_release -c -s` main"
apt-get update
apt-get install -y qgis qgis-plugin-grass
#wget -qO - https://qgis.org/downloads/qgis-2020.gpg.key | sudo gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/qgis-archive.gpg --import
#sudo chmod a+r /etc/apt/trusted.gpg.d/qgis-archive.gpg


echo "Installing supporting libraries..."

conda clean -i 

#get this gahbage outta here (for now)
#let us see if any of this will let us be ok 
#conda install --override-channels -c conda-forge --yes \
#      'fiona' \
#      'gdal' \
#      'geopandas' \
#      'rasterio' \
#      'r-classInt' \
#      'r-deldir' \
#      'r-geoR' \
#      'r-geosphere' \
#      'r-gstat' \
#      'r-hdf5r' \
#      'r-lidR' \
#      'r-mapdata' \
#      'r-maptools' \
#      'r-mapview' \
#      'r-ncdf4' \
#      'r-proj4' \
#      'r-RandomFields' \
#      'r-raster' \
#      'r-RColorBrewer' \
#      'r-rgdal' \
#      'r-rgeos' \
#      'r-rlas' \
#      'r-RNetCDF' \
#      'r-sf' \
#      'r-sp' \
#      'r-spacetime' \
#      'r-spatstat' \
#      'r-spdep'

#Fix R
conda install -c conda-forge libiconv

conda clean --all -f -y

#Huh, can i change this to NB_UID (we inherit that)
#export USER_GID=${USER_GID}
export NB_UID=${NB_UID}

fix-permissions.sh ${CONDA_DIR}

echo "QGIS and supporting libraries have been installed."
