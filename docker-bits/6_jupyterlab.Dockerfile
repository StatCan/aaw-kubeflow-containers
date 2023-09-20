# installs vscode server, python & conda packages and jupyter lab extensions.

# Using JupyterLab 3.0 inherited docker-stacks base image. A few extensions we used to install do not yet support
# this version of Jupyterlab and/or are not OL-compliant so they have been removed until new compatible versions are available:
    # jupyterlab-kale
    # jupyterlab-variableinspector
    # jupyterlab-archive
    # jupyterlab-spellchecker
    # jupyterlab-spreadsheet

# Install vscode
ARG VSCODE_VERSION=4.14.1
ARG VSCODE_SHA=ee3871c0d441a21da9b199820c105425739892572a6ddd1b9a83bdd44cac8ebb
ARG VSCODE_URL=https://github.com/coder/code-server/releases/download/v${VSCODE_VERSION}/code-server_${VSCODE_VERSION}_amd64.deb
USER root

ENV CS_DISABLE_FILE_DOWNLOADS=1
ENV CS_TEMP_HOME=/etc/share/code-server
ENV CS_DEFAULT_HOME=$HOME/.local/share/code-server
ENV SERVICE_URL=https://extensions.coder.com/api

RUN wget -q "${VSCODE_URL}" -O ./vscode.deb \
    && echo "${VSCODE_SHA}  ./vscode.deb" | sha256sum -c - \
    && wget -q https://github.com/microsoft/vscode-cpptools/releases/download/v1.17.5/cpptools-linux.vsix \
    && apt-get update \
    && apt-get install -y nginx build-essential gdb \
    && dpkg -i ./vscode.deb \
    && rm ./vscode.deb \
    && rm -f /etc/apt/sources.list.d/vscode.list \
    && mkdir -p $CS_TEMP_HOME/Machine

RUN code-server --install-extension ms-python.python@2023.12.0 && \
    code-server --install-extension REditorSupport.r@2.8.1 && \
    code-server --install-extension ms-ceintl.vscode-language-pack-fr@1.79.0 && \
    code-server --install-extension quarto.quarto@1.90.1 && \
    code-server --install-extension databricks.databricks@1.1.0 && \
    code-server --install-extension dvirtz.parquet-viewer@2.3.3 && \
    code-server --install-extension redhat.vscode-yaml@1.14.0 && \
    code-server --install-extension ms-vscode.azurecli@0.5.0 && \
    code-server --install-extension mblode.pretty-formatter@0.2.1 && \
    code-server --install-extension cpptools-linux.vsix && \
    mv $CS_DEFAULT_HOME/* $CS_TEMP_HOME && \
    fix-permissions $CS_TEMP_HOME

COPY vscode-overrides.json $CS_TEMP_HOME/Machine/settings.json
# Fix for VSCode extensions and CORS
# Languagepacks.json needs to exist for code-server to recognize the languagepack
COPY languagepacks.json $CS_TEMP_HOME/

# Default environment
RUN pip3 --no-cache-dir install --quiet \
    'pillow==10.0.0' \
    'notebook==7.0.2' \
    'pyyaml==6.0.1' \
    'jupyter-lsp==2.2.0' \
    'jupyter-server-proxy==4.0.0' \
    'jupyter_contrib_nbextensions==0.7.0' && \
  fix-permissions $CONDA_DIR && \
  fix-permissions /home/$NB_USER

RUN pip3 --no-cache-dir install --quiet \
    'jupyterlab_execute_time==3.0.1'

RUN pip3 --no-cache-dir install --quiet \
    'jupyterlab-git==0.42.0'

RUN pip3 --no-cache-dir install --quiet \
    'jupyterlab-lsp==4.2.0'

RUN pip3 --no-cache-dir install --quiet \
    'jupyterlab-language-pack-fr-FR==4.0.post0'

RUN pip3 --no-cache-dir install --quiet \
    'markupsafe==2.1.3' \
    'ipywidgets==8.1.0' \
    'ipympl==0.9.3'

RUN mamba install --quiet --yes -c conda-forge \
    'nb_conda_kernels==2.3.1'

RUN pip install 'git+https://github.com/betatim/vscode-binder'

RUN mamba install --quiet --yes -c conda-forge -c plotly \
    jupyter-dash && \
    jupyter lab build

RUN mamba clean --all -f -y && \
    jupyter serverextension enable --py jupyter_server_proxy && \
    jupyter nbextension enable codefolding/main --sys-prefix && \
    jupyter labextension install \
      '@jupyterlab/translation-extension' \
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
      'jupyterlab==4.0.5' && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER && \
    jupyter lab build && \
    jupyter lab clean && \

# Install python, R, Julia and other useful language servers
RUN julia -e 'using Pkg; Pkg.add("LanguageServer")' && \
    /opt/conda/bin/R --silent --slave --no-save --no-restore -e 'install.packages("languageserver", repos="https://cran.r-project.org/")' && \
    conda install -c conda-forge \
      'r-languageserver' \
      'python-lsp-server' \
    && \
    npm i -g \
    'bash-language-server'  \
    'dockerfile-language-server-nodejs' \
    'javascript-typescript-langserver' \
    'unified-language-server' \
    'yaml-language-server@0.18.0' && \
    mamba clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Solarized Theme and Cell Execution Time
COPY jupyterlab-overrides.json /opt/conda/share/jupyter/lab/settings/overrides.json

ENV DEFAULT_JUPYTER_URL=/lab
ENV GIT_EXAMPLE_NOTEBOOKS=https://github.com/StatCan/aaw-contrib-jupyter-notebooks
