# Install PyTorch
RUN conda create -n torch python=3.7 && \
    conda install -n torch --quiet --yes -c pytorch \
      'pytorch==1.6.0' \
      'torchvision==0.7.0' \
      'ipykernel==5.3.4' \
    && \
    conda install -n torch --quiet --yes -c pytorch \
      'torchtext==0.7.0' \
    && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER