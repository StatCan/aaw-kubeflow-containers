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
    'yaml-language-server@0.18.0'  && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER  \
    && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# OpenM install
# Install OpenM++ MPI
ARG OMPP_VERSION="1.15.4"
# IMPORTANT: Don't forget to update the version number in the openmpp.desktop file!!
ARG OMPP_PKG_DATE="20230803"
ARG SHA256ompp=5da79984ef67ad16b3b7d429896b8a553930ca46a16079aaef24b3c9dc867956
# OpenM++ environment settings
ENV OMPP_INSTALL_DIR=/opt/openmpp/${OMPP_VERSION}

COPY jupyter-ompp-proxy/ /opt/jupyter-ompp-proxy/

# OpenM++ expects sqlite to be installed (not just libsqlite)
# Customize and rebuild omp-ui for jupyter-ompp-proxy install
# issue with making a relative publicPath https://github.com/quasarframework/quasar/issues/8513
RUN apt-get install --yes sqlite3 \
    && wget -q https://github.com/openmpp/main/releases/download/v${OMPP_VERSION}/openmpp_debian_${OMPP_PKG_DATE}.tar.gz -O /tmp/ompp.tar.gz \
    && echo "${SHA256ompp} /tmp/ompp.tar.gz" | sha256sum -c - \
    && mkdir -p ${OMPP_INSTALL_DIR} \
    && tar -xf /tmp/ompp.tar.gz -C ${OMPP_INSTALL_DIR} --strip-components=1 \
    && rm -f /tmp/ompp.tar.gz \
    && sed -i -e 's/history/hash/' ${OMPP_INSTALL_DIR}/ompp-ui/quasar.conf.js \
    && sed -i -e "s/OMS_URL:.*''/OMS_URL: '.'/" ${OMPP_INSTALL_DIR}/ompp-ui/quasar.conf.js \
    && npm install --prefix ${OMPP_INSTALL_DIR}/ompp-ui \
    && npm run build --prefix ${OMPP_INSTALL_DIR}/ompp-ui \
    && rm -r ${OMPP_INSTALL_DIR}/html \
    && mv ${OMPP_INSTALL_DIR}/ompp-ui/dist/spa ${OMPP_INSTALL_DIR}/html \
    && fix-permissions ${OMPP_INSTALL_DIR} \
    && pip install /opt/jupyter-ompp-proxy/

# Solarized Theme and Cell Execution Time
COPY jupyterlab-overrides.json /opt/conda/share/jupyter/lab/settings/overrides.json

ENV DEFAULT_JUPYTER_URL=/lab
ENV GIT_EXAMPLE_NOTEBOOKS=https://github.com/StatCan/aaw-contrib-jupyter-notebooks