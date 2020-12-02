# Install vscode
ARG CODESERVER_URL="https://github.com/cdr/code-server/releases/download/1.1119-vsc1.33.1/code-server1.1119-vsc1.33.1-linux-x64.tar.gz"
ARG CODESERVER="code-server1.1119-vsc1.33.1-linux-x64"
ARG CODESERVER_SHA=dcd024301226eb493db2d06454b5d57a3499fbbc17fd816a68a2333ee3482685

ARG VSCODE_VERSION=3.6.2
ARG VSCODE_SHA=71edb5776a7f965bf720c9814ab2e762fbaa0ddad4d9f4f85848c3912df1b67c
ARG VSCODE_URL=https://github.com/cdr/code-server/releases/download/v${VSCODE_VERSION}/code-server_${VSCODE_VERSION}_amd64.deb

USER root
RUN wget -q "${VSCODE_URL}" -O ./vscode.deb \
    && echo "${VSCODE_SHA}  ./vscode.deb" | sha256sum -c - \
    && apt-get update \
    && apt-get install -y nginx \
    && apt-get install -y ./vscode.deb \
    && rm ./vscode.deb \
    && rm -f /etc/apt/sources.list.d/vscode.list \
    && echo "Install codeserver" \
    && wget -q ${CODESERVER_URL} \
    && echo "${CODESERVER_SHA}  ${CODESERVER}.tar.gz" | sha256sum -c - \
    && tar xvf ${CODESERVER}.tar.gz \
    && mv ${CODESERVER}/code-server /usr/local/bin/ \
    && rm -rf code-server*

# Default environment
RUN pip install --quiet \
      'jupyter-lsp' \
      'jupyter-server-proxy' \
      'git+https://github.com/blairdrummond/vscode-binder' \
    && \
    conda install --quiet --yes \
    -c conda-forge \
      'ipympl' \
      'jupyter_contrib_nbextensions' \
      'nb_conda_kernels' \
      'jupyterlab-git' \
      'nodejs' \
      'python-language-server' \
    && \
    conda install --quiet --yes \
      -c plotly \
      'jupyter-dash' \
    && \
    conda clean --all -f -y && \
    jupyter serverextension enable --py jupyter_server_proxy && \
    jupyter nbextension enable codefolding/main --sys-prefix && \
    jupyter labextension install --no-build \
      '@ijmbarr/jupyterlab_spellchecker' \
      '@hadim/jupyter-archive' \
      '@krassowski/jupyterlab-lsp' \
      '@lckr/jupyterlab_variableinspector' \
      '@jupyterlab/github' \
      '@jupyterlab/git' \
      '@jupyterlab/server-proxy' \
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
