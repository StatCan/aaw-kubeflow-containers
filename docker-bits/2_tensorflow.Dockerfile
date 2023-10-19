# Install Tensorflow
RUN mamba install --quiet --yes \
        tensorflow \
        keras \
        ipykernel \
    && \
    clean-layer.sh && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER
