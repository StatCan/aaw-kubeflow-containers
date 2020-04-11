FROM k8scc01covidacr.azurecr.io/base-notebook-cpu:master
USER root

# Dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      'htop' \
      'tree' \
      'vim' \
      'tig' \
      'ranger' \
      'curl' \
      'jq' \
      'zsh' \
    && \
    rm -rf /var/lib/apt/lists/*

# Default environment
RUN pip install --quiet \
      'jupyter-git' \
      'jupyter-lsp' \
    && \
    conda install --quiet --yes \
    -c conda-forge \
      'ipywidgets' \
      'ipympl' \
      'jupyter_contrib_nbextensions' \
      'jupyterlab-dash' \
      'nodejs' \
      'python-language-server' \
    && \
    conda install --quiet --yes \
      'r-dplyr' \
      'r-rstan' \
    && \
    conda clean --all -f -y && \
    jupyter nbextension enable codefolding/main --sys-prefix && \
    jupyter labextension install --no-build \
      '@ijmbarr/jupyterlab_spellchecker' \
      '@jupyterlab/toc' \
      '@jupyter-widgets/jupyterlab-manager'  \
      '@krassowski/jupyterlab-lsp' \
      '@lckr/jupyterlab_variableinspector' \
      'jupyter-matplotlib' \
      'jupyterlab-plotly' \
    && \
    jupyter lab build && \
    jupyter lab clean && \
    npm cache clean --force && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    rm -rf /home/$NB_USER/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Configure container startup
EXPOSE 8888
USER jovyan
ENTRYPOINT ["tini", "--"]
CMD ["start-custom.sh"]
