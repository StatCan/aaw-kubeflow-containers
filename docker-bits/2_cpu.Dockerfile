# Install PyTorch and Tensorflow (CPU only).
RUN mamba install --quiet --yes -c pytorch -c conda-forge \
        python=3.11 \
        pytorch \
        torchvision \
        torchaudio \
        cpuonly \
        tensorflow && \
    mamba clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER
