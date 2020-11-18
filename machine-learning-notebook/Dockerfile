ARG BASE_CONTAINER
FROM $BASE_CONTAINER
USER root

# Install Tensorflow

# Install Tensorflow, check compatibility here: https://www.tensorflow.org/install/gpu
# installation via conda leads to errors in version 4.8.2
RUN pip install --no-cache-dir "tensorflow==2.1.*" && \
    pip install --no-cache-dir "keras==2.4.3" && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Pytorch via pip
# conda install here gave environment inconsistency/version problems as of 2020-09-15
# cu version must match that inherited from upstream GPU drivers
RUN pip install --no-cache-dir \
    torch==1.6.0+cu101 \
    torchvision==0.7.0+cu101 \
    torchtext==0.7.0 \
    -f https://download.pytorch.org/whl/torch_stable.html && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Install XGBoost
RUN conda config --set channel_priority false && \
    conda install --quiet --yes \
      'xgboost==1.2.0' \
    && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Configure container startup
EXPOSE 8888
USER jovyan
ENTRYPOINT ["tini", "--"]
CMD ["start-custom.sh"]