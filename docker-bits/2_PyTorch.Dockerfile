# Install PyTorch
RUN conda create -n torch python=3.7 && \
    conda install -n torch --quiet --yes \
      'pytorch-gpu=1.3.1' \
      'torchvision=0.4.2' \
      'ipykernel==5.3.4' \
    && \
    conda install -n torch -c pytorch --quiet --yes \
      'torchtext=0.6.0' \
    && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER
