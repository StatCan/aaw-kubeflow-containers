# Create conda environment (CPU only) with many useful packages.

RUN conda create -n pycpu --yes \
      python==3.8.8 ipython==7.30.1 \
      gdal==3.3.3 geopandas==0.10.2 numpy==1.21.4 opencv==4.5.3 pandas==1.3.5 rasterio==1.2.10 scikit-learn==1.0.1 scipy==1.7.3 xgboost==1.5.0 \
      pytorch==1.4.0 torchaudio==0.4.0 torchvision==0.5.0 cpuonly==2.0 \
      -c pytorch -c conda-forge && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER
