# Install PyTorch
RUN mamba install -c pytorch -c nvidia \
        pytorch \
        torchvision \
        torchaudio \
        pytorch-cuda=11.8 \
        ipykernel \
    && \
    mamba clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER
