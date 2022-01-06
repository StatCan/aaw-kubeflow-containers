# Create conda environment (CPU only) with many useful packages.

RUN conda create -n pycpu --yes \
      python==3.8.12 ipython==7.31.0 \
      sphinx==4.3.2 \
      boto==2.49.0 s3fs==2021.11.1 \
      dos2unix==7.4.1 \
      dask==2021.12.0 numpy==1.22.0 pandas==1.3.5 pyarrow==6.0.1 scipy==1.7.3 \
      scikit-learn==1.0.2 xgboost==1.5.0 \
      matplotlib==3.5.1 pillow==8.4.0 \
      gdal==3.4.0 geopandas==0.10.2 rasterio==1.2.10 \
      opencv==4.5.3 scikit-image==0.19.1 \
      gensim==4.1.2 nltk==3.6.7 spacy==3.2.1 \
      pytorch==1.10.1 torchaudio==0.10.1 torchvision==0.11.2 cpuonly==2.0 \
      -c pytorch -c conda-forge && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER
