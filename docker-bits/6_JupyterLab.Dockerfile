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
      'jupyter-lsp==0.9.3' \
      'jupyter-server-proxy==1.5.0' \
      'git+https://github.com/blairdrummond/vscode-binder' \
    && \
    conda install --quiet --yes \
    -c conda-forge \
      'ipympl==0.5.8' \
      'jupyter_contrib_nbextensions==0.5.1' \
      'nb_conda_kernels==2.3.1' \
      'jupyterlab-git==0.23.2' \
      'nodejs==14.14.0' \
      'python-language-server==0.36.2' \
    && \
    conda install --quiet --yes \
      -c plotly \
      'jupyter-dash==0.3.0' \
    && \
    conda clean --all -f -y && \
    jupyter serverextension enable --py jupyter_server_proxy && \
    jupyter nbextension enable codefolding/main --sys-prefix && \
    jupyter labextension install --no-build \
      '@ijmbarr/jupyterlab_spellchecker@0.2.0' \
      '@hadim/jupyter-archive@0.7.0' \
      '@krassowski/jupyterlab-lsp@2.1.0' \
      '@lckr/jupyterlab_variableinspector@0.5.1' \
      '@jupyterlab/github@2.0.0' \
      '@jupyterlab/git@0.23.2' \
      '@jupyterlab/server-proxy@2.1.1' \
      '@jupyterlab/toc@4.0.0' \
      'jupyterlab-execute-time@1.0.0' \
      'jupyterlab-plotly@4.14.1' \
      'jupyterlab-theme-solarized-dark@1.0.3' \
      'jupyterlab-spreadsheet@0.3.2' \
      'nbdime-jupyterlab@2.0.1' \
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
