FROM k8scc01covidacr.azurecr.io/minimal-notebook-cpu:master
USER root

RUN conda install --quiet --yes \
      'fiona==1.8.17' \
      'gdal==3.1.2' \
      'geopandas==0.8.1' \
      'rasterio==1.1.6' \
      'r-classInt==0.4_3' \
      'r-deldir==0.1_29' \
      'r-geoR==1.8_1' \
      'r-geosphere==1.5_10' \
      'r-gstat==2.0_6' \
      'r-hdf5r==1.3.3' \
      'r-lidR==3.0.3' \
      'r-mapdata==2.3.0' \
      'r-maptools==1.0_2' \
      'r-mapview==2.9.0' \
      'r-ncdf4==1.17' \
      'r-proj4==1.0_10' \
      'r-RandomFields==3.3.8' \
      'r-raster==3.3_13' \
      'r-rgdal==1.5_16' \
      'r-rgeos==0.5_5' \
      'r-rlas==1.3.6' \
      'r-RNetCDF==2.4_2' \
      'r-sf==0.9_6' \
      'r-sp==1.4_2' \
      'r-spacetime==1.2_3' \
      'r-spatstat==1.64_1' \
      'r-spdep==1.1_5' \
    && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Configure container startup
EXPOSE 8888
USER jovyan
ENTRYPOINT ["tini", "--"]
CMD ["start-custom.sh"]
