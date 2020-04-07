# https://github.com/jupyter/docker-stacks/blob/master/datascience-notebook/Dockerfile
FROM k8scc01covidacr.azurecr.io/minimal-notebook:master
USER root


# This list is taken from the rocker/geospatial image
# It's a good set for geomatics. Packages which were previously
# omitted were skipped because I couldn't get them to compile :S
RUN conda install --quiet --yes \
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
      'r-spdep' \


# I think conda is managing this for us
#
# # # Dependencies
# # RUN apt-get update && \
# #     apt-get install -y --no-install-recommends \
# #       'lbzip2' \
# #       'libfftw3-dev' \
# #       'libgdal-dev' \
# #       'libgeos-dev' \
# #       'libgsl0-dev' \
# #       'libgl1-mesa-dev' \
# #       'libglu1-mesa-dev' \
# #       'libhdf4-alt-dev' \
# #       'libhdf5-dev' \
# #       'libjq-dev' \
# #       'liblwgeom-dev' \
# #       'libpq-dev' \
# #       'libproj-dev' \
# #       'libprotobuf-dev' \
# #       'libnetcdf-dev' \
# #       'libsqlite3-dev' \
# #       'libssl-dev' \
# #       'libudunits2-dev' \
# #       'netcdf-bin' \
# #       'postgis' \
# #       'protobuf-compiler' \
# #       'sqlite3' \
# #       'tk-dev' \
# #       'unixodbc-dev' \
# #     && \
# #     rm -rf /var/lib/apt/lists/*

# Configure container startup
EXPOSE 8888
USER jovyan
ENTRYPOINT ["tini", "--"]
CMD ["sh","-c", "jupyter notebook --notebook-dir=/home/${NB_USER} --ip=0.0.0.0 --no-browser --allow-root --port=8888 --NotebookApp.token='' --NotebookApp.password='' --NotebookApp.allow_origin='*' --NotebookApp.base_url=${NB_PREFIX} --NotebookApp.default_url='/lab'"]
