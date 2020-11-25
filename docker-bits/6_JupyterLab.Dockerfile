# Default environment
RUN pip install --quiet \
      'jupyter-lsp' \
      'jupyter-server-proxy' \
    && \
    conda install --quiet --yes \
    -c conda-forge \
      'ipympl' \
      'jupyter_contrib_nbextensions' \
      'jupyterlab-git' \
      'xeus-python' \
      'nodejs' \
      'python-language-server' \
    && \
    conda install --quiet --yes \
      -c plotly \
      'jupyter-dash' \
    && \
    conda clean --all -f -y && \
    jupyter nbextension enable codefolding/main --sys-prefix && \
    jupyter labextension install --no-build \
      '@ijmbarr/jupyterlab_spellchecker' \
      '@hadim/jupyter-archive' \
      '@krassowski/jupyterlab-lsp' \
      '@lckr/jupyterlab_variableinspector' \
      '@jupyterlab/debugger' \
      '@jupyterlab/github' \
      '@jupyterlab/git' \
      '@jupyterlab/toc' \
      'jupyterlab-execute-time' \
      'jupyterlab-plotly' \
      'jupyterlab-theme-solarized-dark' \
      'jupyterlab-spreadsheet' \
      'nbdime-jupyterlab' \
    && \
    jupyter lab build && \
    jupyter lab clean && \
  npm cache clean --force && \
  rm -rf /home/$NB_USER/.cache/yarn && \
  rm -rf /home/$NB_USER/.node-gyp && \
  fix-permissions $CONDA_DIR && \
  fix-permissions /home/$NB_USER

# Solarized Theme and Cell Execution Time
COPY jupyterlab-overrides.json /opt/conda/share/jupyter/lab/settings/overrides.json

ENV DEFAULT_JUPYTER_URL=/lab
ENV GIT_EXAMPLE_NOTEBOOKS=https://github.com/statcan/jupyter-notebooks
