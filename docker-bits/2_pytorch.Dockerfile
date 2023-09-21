# Install PyTorch GPU Packages and enable PyTorch IPyKernel
RUN mamba create -n torch && \
    mamba install -n torch --quiet --yes -c pytorch -c nvidia \
        python=3.11 \
        ipykernel \
        pytorch \
        torchvision \
        torchaudio \
        # gputil has nvidia-smi
        gputil \
        # pytorch-cuda are the nvidia cuda drivers
        pytorch-cuda=11.8 && \
    mamba clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER && \
    python -m ipykernel install --user --name torch --display-name "PyTorch"

