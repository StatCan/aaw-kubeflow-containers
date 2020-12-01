# Install Tensorflow
RUN conda config --set channel_priority false && \
    conda create -n tensorflow && \
    conda install -n tensorflow --quiet --yes \
      'tensorflow-gpu' \
      'keras' \
      'ipykernel' \
    && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER
