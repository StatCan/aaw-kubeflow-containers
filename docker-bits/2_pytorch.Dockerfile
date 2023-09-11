# Install PyTorch GPU Packages and enable PyTorch IPyKernel
RUN mamba install --quiet --yes -c pytorch -c nvidia \
        python=3.11 \
        pytorch \
        torchvision \
        torchaudio \
        # gputil has nvidia-smi
        gputil \
        # pytorch-cuda are the nvidia cuda drivers
        pytorch-cuda=11.8 && \
    mamba clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

