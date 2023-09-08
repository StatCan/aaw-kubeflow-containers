# Install PyTorch GPU Packages and enable PyTorch IPyKernel
RUN mamba create -n torch python=3.11 && \
    mamba install -n torch --quiet --yes -c pytorch -c nvidia \
        ipykernel \
        pytorch \
        torchvision \
        torchaudio \
        pytorch-cuda=11.8 \
    && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER && \
    source activate torch && \
    python -m ipykernel install --user --name torch --display-name "PyTorch"


