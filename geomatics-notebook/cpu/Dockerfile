FROM k8scc01covidacr.azurecr.io/minimal-notebook-cpu:master
USER root

RUN conda install --quiet --yes \
      'fiona' \
      'gdal' \
      'geopandas' \
      'postal' \
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
      'r-spdep' \
    && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Configure container startup
EXPOSE 8888
USER jovyan
ENTRYPOINT ["tini", "--"]
CMD ["start-custom.sh"]
