# Install PyTorch
RUN conda config --set channel_priority false && \
    conda create -n torch python=3.7 && \
    conda install -n torch --quiet --yes \
      'pytorch-gpu' \
      'torchvision' \
      'ipykernel' \
    && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER
