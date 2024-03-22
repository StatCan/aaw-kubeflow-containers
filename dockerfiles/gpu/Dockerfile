FROM zone-jupyterlab AS zone-jupyterlab-gpu

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
    clean-layer.sh && \ 
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER && \
    python -m ipykernel install --user --name torch --display-name "PyTorch"

RUN mamba create -n tensorflow && \
    mamba install --quiet --yes -c anaconda -c conda-forge -c nvidia \
        python=3.11 \
        tensorflow \
        cudatoolkit=11.8 \
        cudnn \
        # gputil has nvidia-smi
        gputil \
        ipykernel && \
    clean-layer.sh && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER && \
    python -m ipykernel install --user --name tensorflow --display-name "TensorFlow"

