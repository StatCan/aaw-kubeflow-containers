FROM k8scc01covidacr.azurecr.io/minimal-notebook-cpu:master
USER root

# Install Tensorflow
RUN conda config --set channel_priority false && \
    conda install --quiet --yes \
      'tensorflow=2.1*' \
      'keras' \
    && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Install PyTorch
RUN conda config --set channel_priority false && \
    conda install --quiet --yes \
      'cmake' \
      'cffi' \
      'mkl' \
      'mkl-include' \
      'pyyaml' \
      'setuptools' \
      'typing' \
    && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

RUN conda config --set channel_priority false && \
    conda install --quiet --yes \
     'pytorch' \
     'torchvision' \
    && \
    conda install --quiet --yes \
    -c pytorch \
      'torchtext' \
    && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Configure container startup
EXPOSE 8888
USER jovyan
ENTRYPOINT ["tini", "--"]
CMD ["start-custom.sh"]
