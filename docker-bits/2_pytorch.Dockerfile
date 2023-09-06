# Install PyTorch
RUN pip3 install \
        torch \
        torchvision \
        torchaudio \
        --index-url https://download.pytorch.org/whl/cu118 \
        ipykernel \
    && \
    mamba clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER
