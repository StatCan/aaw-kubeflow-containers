# Install PyTorch
RUN conda create -n torch python=3.9 && \
   conda install -n torch --quiet --yes -c pytorch \
     'pytorch==1.13.1' \
     'torchvision==0.14.1' \
     'ipykernel==6.21.3' \
     'torchtext==0.14.1' \
   && \
   conda clean --all -f -y && \
   fix-permissions $CONDA_DIR && \
   fix-permissions /home/$NB_USER
