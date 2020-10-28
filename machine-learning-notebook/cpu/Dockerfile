FROM k8scc01covidacr.azurecr.io/minimal-notebook-cpu:master
USER root

# Install Tensorflow
RUN pip --no-cache-dir install --quiet \
     'tensorflow==2.3.1' \
     'keras==2.4.3' \
    && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Install PyTorch
RUN conda config --set channel_priority false && \
    conda install --quiet --yes \
      'cmake==3.18.2' \
      'cffi==1.14.3' \
      'mkl==2020.2' \
      'mkl-include==2020.2' \
      'pyyaml==5.3.1' \
      'setuptools==49.6.0' \
      'typing==3.7.4.3' \
    && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

RUN pip --no-cache-dir install --quiet \
     'torch==1.6.0' \
     'torchvision==0.7.0' \
     'torchtext==0.7.0' \
    && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Configure container startup
EXPOSE 8888
USER jovyan
ENTRYPOINT ["tini", "--"]
CMD ["start-custom.sh"]
