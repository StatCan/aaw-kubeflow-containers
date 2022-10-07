# Create conda environment (CPU only) with many useful packages.

RUN conda create -n pycpu --yes \
      python==3.10.4 ipython==8.4.0 sphinx==5.0.0 \
      boto==2.49.0 s3fs==2022.5.0 \
      dos2unix==7.4.1 parallel==20220522 \
      dask==2022.5.2 numpy==1.22.4 pandas==1.4.2 pyarrow==8.0.0 scipy==1.9.1 \
      scikit-learn==1.1.2 xgboost==1.5.1 \
      matplotlib==3.5.2 pillow==9.1.1 \
      gdal==3.4.3 geopandas==0.10.2 rasterio==1.2.10 \
      opencv==4.5.5 scikit-image==0.19.2 \
      gensim==4.2.0 nltk==3.6.7 spacy==3.3.0 \
      pytorch==1.11.0 torchaudio==0.11.0 torchvision==0.12.0 cpuonly==2.0 \
      -c pytorch -c conda-forge && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER
