# Install Tensorflow
RUN mamba install --quiet --yes -c anaconda -c conda-forge -c nvidia \
        python=3.11 \
        tensorflow \
        cudatoolkit=11.8 \
        cudnn \
        # gputil has nvidia-smi
        gputil && \
    mamba clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER
