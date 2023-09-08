# Install PyTorch
RUN mamba install \
    python \
    pytorch \
    torchvision \
    torchaudio \
    pytorch-cuda \
    -c pytorch \
    -c nvidia \
    && \
    mamba clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER
