FROM jupyter/datascience-notebook
#FROM jupyter/r-notebook

# Extensions
RUN conda update jupyterlab && \
    # Code folding
    conda install -c conda-forge jupyter_contrib_nbextensions && \
    jupyter nbextension enable codefolding/main && \
    # IPyWidgets
    conda install -c conda-forge ipywidgets  && \
    jupyter labextension install @jupyter-widgets/jupyterlab-manager && \
    # Dash
    conda install -c conda-forge jupyterlab-dash && \
    # Variable Inspector
    jupyter labextension install @lckr/jupyterlab_variableinspector && \
    # Matplotlib integration
    conda install -c conda-forge ipympl nodejs && \
    jupyter labextension install @jupyter-widgets/jupyterlab-manager jupyter-matplotlib && \
    # Plotly
    jupyter labextension install jupyterlab-plotly && \
    # Spellcheck
    jupyter labextension install @ijmbarr/jupyterlab_spellchecker && \
    # Git
    pip install --upgrade jupyterlab-git && \
    jupyter lab build && \
    # Table of Contents
    jupyter labextension install @jupyterlab/toc
    # Google Drive
    #jupyter labextension install @jupyterlab/google-drive && \
    # Comments
    #pip install jupyterlab-commenting-service && \
    #jupyter labextension install @jupyterlab/commenting-extension

# At Ken's request
RUN Rscript -e 'install.packages("rstan", repos="http://cran.rstudio.com")'

# Language Server
RUN pip install --upgrade jupyter-lsp && jupyter labextension install @krassowski/jupyterlab-lsp

USER root
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    lbzip2 \
    libfftw3-dev \
    libgdal-dev \
    libgeos-dev \
    libgsl0-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libhdf4-alt-dev \
    libhdf5-dev \
    libjq-dev \
    liblwgeom-dev \
    libpq-dev \
    libproj-dev \
    libprotobuf-dev \
    libnetcdf-dev \
    libsqlite3-dev \
    libssl-dev \
    libudunits2-dev \
    netcdf-bin \
    postgis \
    protobuf-compiler \
    sqlite3 \
    tk-dev \
    unixodbc-dev

# Geomatics
RUN conda install rasterio gdal r-rgdal r-raster r-geoR

USER jovyan
CMD ["sh","-c", "jupyter notebook --notebook-dir=/home/jovyan --ip=0.0.0.0 --no-browser --allow-root --port=8888 --NotebookApp.token='' --NotebookApp.password='' --NotebookApp.default_url='/lab' --NotebookApp.allow_origin='*' --NotebookApp.base_url=${NB_PREFIX}"]
