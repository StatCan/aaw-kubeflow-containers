# Install Tensorflow
RUN pip install --quiet \
        'tensorflow' \
        'keras' \
        'ipykernel==5.3.4' \
    && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER
