# Create conda environment (CPU only) with many useful packages.

RUN conda create -n pycpu --yes \
      python==3.11.0 ipython==8.11.0 \
      -c pytorch -c conda-forge && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER
