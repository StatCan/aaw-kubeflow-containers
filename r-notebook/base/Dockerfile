# https://github.com/jupyter/docker-stacks/blob/master/datascience-notebook/Dockerfile
FROM jupyter/datascience-notebook
USER root

# Dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      'lbzip2' \
      'libfftw3-dev' \
      'libgdal-dev' \
      'libgeos-dev' \
      'libgsl0-dev' \
      'libgl1-mesa-dev' \
      'libglu1-mesa-dev' \
      'libhdf4-alt-dev' \
      'libhdf5-dev' \
      'libjq-dev' \
      'liblwgeom-dev' \
      'libpq-dev' \
      'libproj-dev' \
      'libprotobuf-dev' \
      'libnetcdf-dev' \
      'libsqlite3-dev' \
      'libssl-dev' \
      'libudunits2-dev' \
      'netcdf-bin' \
      'postgis' \
      'protobuf-compiler' \
      'sqlite3' \
      'tk-dev' \
      'unixodbc-dev' \
    && \
    rm -rf /var/lib/apt/lists/*

# Install Python 3 packages
RUN pip install \
      'jupyter-git' \
      'jupyter-lsp' \
    && \
    conda install --quiet --yes \
    -c conda-forge \
      'ipywidgets' \
      'ipympl' \
      'jupyter_contrib_nbextensions' \
      'jupyterlab-dash' \
      'nodejs' \
      'python-language-server' \
    && \
    conda install --quiet --yes \
      'gdal' \
      'rasterio' \
      'r-geoR' \
      'r-raster' \
      'r-rgdal' \
      'r-rstan' \
    && \
    conda clean --all -f -y && \
    jupyter nbextension enable codefolding/main --sys-prefix && \
    jupyter labextension install --no-build \
      '@ijmbarr/jupyterlab_spellchecker' \
      '@jupyterlab/toc' \
      '@jupyter-widgets/jupyterlab-manager'  \
      '@krassowski/jupyterlab-lsp' \
      '@lckr/jupyterlab_variableinspector' \
      'jupyter-matplotlib' \
      'jupyterlab-plotly' \
    && \
    jupyter lab build && \
    jupyter lab clean && \
    npm cache clean --force && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    rm -rf /home/$NB_USER/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Configure container startup
EXPOSE 8888
USER jovyan
ENTRYPOINT ["tini", "--"]
CMD ["sh","-c", "jupyter notebook --notebook-dir=/home/${NB_USER} --ip=0.0.0.0 --no-browser --allow-root --port=8888 --NotebookApp.token='' --NotebookApp.password='' --NotebookApp.allow_origin='*' --NotebookApp.base_url=${NB_PREFIX} --NotebookApp.default_url='/lab'"]
