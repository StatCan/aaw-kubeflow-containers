# Install PyTorch
RUN mamba install \
    pytorch \
    torchvision \
    torchaudio \
    pytorch-cuda=11.8 \
    -c pytorch \
    -c nvidia \
    && \
    mamba clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER
