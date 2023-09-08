# Create conda environment (CPU only) with many useful packages.
RUN mamba install pytorch \
        torchvision \
        torchaudio \
        cpuonly \
        -c pytorch && \
    mamba clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER
