#!/bin/bash
# Stops script execution if a command has an error
set -e

if ! hash qgis 2>/dev/null; then
    sh -c 'echo "deb http://qgis.org/debian bionic main" >> /etc/apt/sources.list'  
	sh -c 'echo "deb-src http://qgis.org/debian bionic main " >> /etc/apt/sources.list'  
	wget -O - https://qgis.org/downloads/qgis-2019.gpg.key | gpg --import
	gpg --fingerprint 51F523511C7028C3
	gpg --export --armor 51F523511C7028C3 | apt-key add -
	apt-get update
    LD_LIBRARY_PATH="" LD_PRELOAD="" apt-get install --yes qgis python-qgis

    echo "[Desktop Entry]
	Version=1.0
	Type=Application
	Name=QGIS Desktop
	Comment=
	Exec=/usr/bin/qgis %F
	Icon=qgis
	Path=
	Terminal=false
	StartupNotify=false" >> "/home/joyvan/Desktop/QGIS Desktop.desktop"

	chmod +x "/home/joyvan/Desktop/QGIS Desktop.desktop"
else
    echo "QGIS is already installed"
fi

echo "Installing supporting libraries..."

conda clean -i 

conda install --yes \
      'fiona' \
      'gdal' \
      'geopandas' \
      'rasterio' \
      'r-classInt' \
      'r-deldir' \
      'r-geoR' \
      'r-geosphere' \
      'r-gstat' \
      'r-hdf5r' \
      'r-lidR' \
      'r-mapdata' \
      'r-maptools' \
      'r-mapview' \
      'r-ncdf4' \
      'r-proj4' \
      'r-RandomFields' \
      'r-raster' \
      'r-RColorBrewer' \
      'r-rgdal' \
      'r-rgeos' \
      'r-rlas' \
      'r-RNetCDF' \
      'r-sf' \
      'r-sp' \
      'r-spacetime' \
      'r-spatstat' \
      'r-spdep'

conda clean --all -f -y
export USER_GID=1000
fix-permissions.sh $CONDA_DIR
fix-permissions.sh /home/joyvan

echo "QGIS and supporting libraries have been installed."