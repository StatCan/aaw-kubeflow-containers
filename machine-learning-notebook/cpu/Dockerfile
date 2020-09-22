FROM k8scc01covidacr.azurecr.io/minimal-notebook-cpu:master
USER root

# Install Tensorflow
RUN conda config --set channel_priority false && \
    conda install --quiet --yes \
      'tensorflow=2.1*' \
      'keras==2.3.1' \
    && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Install PyTorch
RUN conda config --set channel_priority false && \
    conda install --quiet --yes \
      'cmake==3.14.0' \
      'cffi==1.14.1' \
      'mkl==2020.2' \
      'mkl-include==2020.2' \
      'pyyaml==5.3.1' \
      'setuptools==49.6.0' \
      'typing==3.7.4.3' \
    && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

RUN conda config --set channel_priority false && \
    conda install --quiet --yes \
     'pytorch==1.3.1' \
     'torchvision==0.4.2' \
    && \
    conda install --quiet --yes \
    -c pytorch \
      'torchtext==0.6.0' \
    && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Configure container startup
EXPOSE 8888
USER jovyan
ENTRYPOINT ["tini", "--"]
CMD ["start-custom.sh"]
