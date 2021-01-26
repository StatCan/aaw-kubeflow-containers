# Install Tensorflow
RUN conda create -n tensorflow && \
    conda install -n tensorflow --quiet --yes \
      'tensorflow-gpu' \
      'keras' \
      'ipykernel==5.3.4' \
    && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER