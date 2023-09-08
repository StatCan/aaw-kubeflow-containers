#Install PyTorch
RUN mamba create -n torch python=3.11 && \
    mamba install -n torch --quiet --yes \
    pytorch \
    torchvision \
    torchaudio \
    pytorch-cuda=11.8 \
    ipykernel \
    -c pytorch \
    -c nvidia && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER && \
    source activate myenv && \
    python -m ipykernel install --user --name torch --display-name "PyTorch"

