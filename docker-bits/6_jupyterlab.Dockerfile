# installs vscode server, python & conda packages and jupyter lab extensions.

# Using JupyterLab 3.0 inherited docker-stacks base image. A few extensions we used to install do not yet support
# this version of Jupyterlab and/or are not OL-compliant so they have been removed until new compatible versions are available:
    # jupyterlab-kale
    # jupyterlab-variableinspector
    # jupyterlab-archive
    # jupyterlab-spellchecker
    # jupyterlab-spreadsheet

# Install vscode
ARG VSCODE_VERSION=4.10.0
ARG VSCODE_SHA=e0746fe7f013d367193060ec40eb81627957d8a8d6b850778a30d56fc54db276
ARG VSCODE_URL=https://github.com/coder/code-server/releases/download/v${VSCODE_VERSION}/code-server_${VSCODE_VERSION}_amd64.deb

USER root

ENV CS_DISABLE_FILE_DOWNLOADS=1
ENV XDG_DATA_HOME=/etc/share
ENV SERVICE_URL=https://extensions.coder.com/api

RUN wget -q "${VSCODE_URL}" -O ./vscode.deb \
    && echo "${VSCODE_SHA}  ./vscode.deb" | sha256sum -c - \
    && apt-get update \
    && apt-get install -y nginx \
    && dpkg -i ./vscode.deb \
    && rm ./vscode.deb \
    && rm -f /etc/apt/sources.list.d/vscode.list \
    && mkdir -p $HOME/.local/share \
    && mkdir -p $XDG_DATA_HOME/code-server/extensions

COPY vscode-overrides.json $XDG_DATA_HOME/code-server/Machine/settings.json
# Fix for VSCode extensions and CORS
# Languagepacks.json needs to exist for code-server to recognize the languagepack
COPY languagepacks.json $XDG_DATA_HOME/code-server/
ARG SHA256py=10368d0175e34583a84935e691dba122d4ece2e23305700f226b6807508a30b1

RUN code-server --install-extension ms-python.python@2022.16.1 && \
    code-server --install-extension REditorSupport.r@2.7.0 && \
    code-server --install-extension ms-ceintl.vscode-language-pack-fr@1.75.0 && \
    code-server --install-extension quarto.quarto@1.53.1 && \
    fix-permissions $XDG_DATA_HOME

# Default environment
RUN pip install --quiet \
      'jupyter-lsp==1.5.1' \
      'jupyter-server-proxy==3.2.2' \
      'jupyterlab_execute_time==2.3.1' \
      'markupsafe==2.1.2' \
      'git+https://github.com/betatim/vscode-binder' \
    && \
    conda install --quiet --yes \
    -c conda-forge \
      'ipywidgets==8.0.4' \
      'ipympl==0.9.3' \
      'jupyter_contrib_nbextensions==0.7.0' \
      'nb_conda_kernels==2.3.1' \
    && \
    conda install --quiet --yes \
      -c plotly \
      'jupyter-dash==0.4.2' \
    && \
    pip install \
      'jupyterlab-git==0.41.0' \
      'jupyterlab-lsp==3.10.2' \
      'jupyterlab-language-pack-fr-FR' \
    && \
    conda clean --all -f -y && \
    jupyter serverextension enable --py jupyter_server_proxy && \
    jupyter nbextension enable codefolding/main --sys-prefix && \
    jupyter labextension install --no-build \
      '@jupyterlab/translation-extension@3.0.4' \
      '@jupyterlab/server-proxy@2.1.2' \
      'jupyterlab-plotly@4.14.3' \
      'nbdime-jupyterlab' \
    && \
    jupyter lab build && \
    jupyter lab clean && \
  npm cache clean --force && \
  rm -rf /home/$NB_USER/.cache/yarn && \
  rm -rf /home/$NB_USER/.node-gyp && \
  fix-permissions $CONDA_DIR && \
  fix-permissions /home/$NB_USER

# Update and pin packages
# See https://github.com/StatCan/aaw-kubeflow-containers/issues/293
RUN pip3 --no-cache-dir install --quiet \
      'pillow==9.4.0' \
      'notebook==6.5.3' \
      'pyyaml==6.0' \
      'jupyterlab==3.6.1' && \
      fix-permissions $CONDA_DIR && \
      fix-permissions /home/$NB_USER

# Install python, R, Julia and other useful language servers
RUN julia -e 'using Pkg; Pkg.add("LanguageServer")' \
    && \
    conda install -c conda-forge \
      'r-languageserver' \
      'python-lsp-server' \
    && \
    npm i -g \
    'bash-language-server'  \
    'dockerfile-language-server-nodejs' \
    'javascript-typescript-langserver' \
    'unified-language-server' \
    'yaml-language-server@0.18.0'  && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER  \
    && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Solarized Theme and Cell Execution Time
COPY jupyterlab-overrides.json /opt/conda/share/jupyter/lab/settings/overrides.json

ENV DEFAULT_JUPYTER_URL=/lab
ENV GIT_EXAMPLE_NOTEBOOKS=https://github.com/StatCan/aaw-contrib-jupyter-notebooks
