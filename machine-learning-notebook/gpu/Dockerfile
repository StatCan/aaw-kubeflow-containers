FROM k8scc01covidacr.azurecr.io/minimal-notebook-gpu:master
USER root

# Install Tensorflow
RUN pip --no-cache-dir install --quiet \
     'tensorflow==2.3.1' \
     'keras==2.4.3' \
    && \
    conda clean --all -f -y && \
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
