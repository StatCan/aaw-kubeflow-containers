# Install Tensorflow
RUN pip install --quiet \
        'tensorflow' \
        'keras' \
        'ipykernel==6.21.3' \
    && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER
