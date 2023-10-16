# Install Tensorflow
RUN mamba install --quiet --yes \
        tensorflow \
        keras \
        ipykernel \
    && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER
