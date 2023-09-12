# Install Tensorflow
RUN mamba create -n tensorflow && \
    mamba install --quiet --yes -c anaconda -c conda-forge -c nvidia \
        python=3.11 \
        tensorflow \
        cudatoolkit=11.8 \
        cudnn \
        # gputil has nvidia-smi
        gputil \
        ipykernel && \
    mamba clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER && \
    python -m ipykernel install --user --name tensorflow --display-name "TensorFlow"
