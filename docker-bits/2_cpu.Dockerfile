# Create conda environment (CPU only) with many useful packages.

RUN conda create -n pycpu --yes \
      python==3.11.0 ipython==8.11.0 sphinx==6.1.3 \
      boto==2.49.0 s3fs==2023.3.0 \
      dos2unix==7.4.1 parallel==20230122 \
      dask==2023.3.0 numpy==1.24.2 pandas==1.5.3 pyarrow==11.0.0 scipy==1.10.1 \
      scikit-learn==1.2.2 xgboost==1.7.1 \
      matplotlib==3.7.1 pillow==9.4.0 \
      gdal==3.6.2 geopandas==0.12.2 rasterio==1.3.6 \
      opencv==4.7.0 scikit-image==0.19.3 \
      gensim==4.3.0 nltk==3.8.1 spacy==3.5.0 \
      pytorch==1.13.1 torchaudio==0.13.1 torchvision==0.14.1 cpuonly==2.0 \
      -c pytorch -c conda-forge && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER
