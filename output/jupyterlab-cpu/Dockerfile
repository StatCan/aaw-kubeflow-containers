
###############################
###  .tmp/cpu.Dockerfile
###############################


###############################
###  docker-bits/0_cpu.Dockerfile
###############################

# Docker-stacks version tags (eg: `r-4.0.3`) are LIVE images that are frequently updated.  To avoid unexpected
# image updates, pin to the docker-stacks git commit SHA tag.
# It can be obtained by running `docker inspect repo/imagename:tag@digest` or from
# https://github.com/jupyter/docker-stacks/wiki

ARG BASE_VERSION=2023-08-07
FROM jupyter/datascience-notebook:$BASE_VERSION

USER root

ENV PATH="/home/jovyan/.local/bin/:${PATH}"

COPY clean-layer.sh /usr/bin/clean-layer.sh

RUN apt-get update --yes \
    && apt-get install --yes language-pack-fr \
    && apt-get upgrade --yes libwebp7 \
    && rm -rf /var/lib/apt/lists/* \
    && chmod +x /usr/bin/clean-layer.sh

###############################
###  docker-bits/3_Kubeflow.Dockerfile
###############################

USER root
COPY aaw-suspend-server.sh /usr/local/bin

# https://github.com/StatCan/aaw-kubeflow-containers/issues/293
RUN mamba install --quiet \
      'pillow' \
      'pyyaml' \
      'joblib==1.2.0' \
      # s3 file system tool forked by Zach, ~4 years old, to be upgraded
      's3fs' \ 
      'fire==0.5.0' \
      'graphviz' && \
      pip install 'kubeflow-training' && \
      clean-layer.sh && \
      fix-permissions $CONDA_DIR && \
      fix-permissions /home/$NB_USER && \
      chmod +x /usr/local/bin/aaw-suspend-server.sh

###############################
###  docker-bits/4_CLI.Dockerfile
###############################

USER root

# Add helpers for shell initialization
COPY shell_helpers.sh /tmp/shell_helpers.sh

# Dependencies
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
      'byobu' \
      'htop' \
      'jq' \
      'openssl' \
      'ranger' \
      'tig' \
      'tmux' \
      'tree' \
      'vim' \
      'zip' \
      'zsh' \
      'dos2unix' \
  && \
    rm -rf /var/lib/apt/lists/*


ARG KUBECTL_VERSION=v1.28.2
ARG KUBECTL_URL=https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl
ARG KUBECTL_SHA=c922440b043e5de1afa3c1382f8c663a25f055978cbc6e8423493ec157579ec5

ARG AZCLI_URL=https://aka.ms/InstallAzureCLIDeb

ARG OH_MY_ZSH_URL=https://raw.githubusercontent.com/loket/oh-my-zsh/feature/batch-mode/tools/install.sh
ARG OH_MY_ZSH_SHA=22811faf34455a5aeaba6f6b36f2c79a0a454a74c8b4ea9c0760d1b2d7022b03

ARG TRINO_URL=https://repo1.maven.org/maven2/io/trino/trino-cli/410/trino-cli-410-executable.jar
ARG TRINO_SHA=f32c257b9cfc38e15e8c0b01292ae1f11bda2b23b5ce1b75332e108ca7bf2e9b

ARG ARGO_CLI_VERSION=v3.4.5
ARG ARGO_CLI_URL=https://github.com/argoproj/argo-workflows/releases/download/${ARGO_CLI_VERSION}/argo-linux-amd64.gz
ARG ARGO_CLI_SHA=0528ff0c0aa87a3f150376eee2f1b26e8b41eb96578c43d715c906304627d3a1 

RUN \
  # OpenJDK-8
    apt-get update && \
    apt-get install -y openjdk-8-jre && \
    apt-get clean && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER \
  && \
    # kubectl
    curl -LO "${KUBECTL_URL}" \
    && echo "${KUBECTL_SHA} kubectl" | sha256sum -c - \
    && chmod +x ./kubectl \
    && sudo mv ./kubectl /usr/local/bin/kubectl \
  && \
    # AzureCLI - installation script from Azure
    curl -sLO "${AZCLI_URL}" \
    && bash InstallAzureCLIDeb \
    && rm InstallAzureCLIDeb \
    && echo "azcli: ok" \
  && \
    # zsh
    wget -q "${OH_MY_ZSH_URL}" -O /tmp/oh-my-zsh-install.sh \
    && echo "${OH_MY_ZSH_SHA} /tmp/oh-my-zsh-install.sh" | sha256sum -c \
    && echo "oh-my-zsh: ok" \
  && \
    # trino cli
    wget -q "${TRINO_URL}" -O /tmp/trino-original \
    && echo ${TRINO_SHA} /tmp/trino-original | sha256sum -c \
    && echo "trinocli: ok" \
    && chmod +x /tmp/trino-original \
    && sudo mv /tmp/trino-original /usr/local/bin/trino-original \
  && \
    # argo cli
    curl -sLO  ${ARGO_CLI_URL}\
    && echo "${ARGO_CLI_SHA}  argo-linux-amd64.gz"  | sha256sum -c - \
    && gunzip argo-linux-amd64.gz \
    && chmod +x argo-linux-amd64 \
    && sudo mv ./argo-linux-amd64 /usr/local/bin/argo \
    && argo version

###############################
###  docker-bits/5_DB-Drivers.Dockerfile
###############################

# ODBC drivers
RUN apt-get update && \
    apt-get install -y unixodbc-dev && \
    pip install --no-cache-dir --quiet pyodbc && \
    rm -rf /var/lib/apt/lists/* && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

###############################
###  docker-bits/6_jupyterlab.Dockerfile
###############################

# installs vscode server, python & conda packages and jupyter lab extensions.

# Using JupyterLab 3.0 inherited docker-stacks base image. A few extensions we used to install do not yet support
# this version of Jupyterlab and/or are not OL-compliant so they have been removed until new compatible versions are available:
    # jupyterlab-kale
    # jupyterlab-variableinspector
    # jupyterlab-archive
    # jupyterlab-spellchecker
    # jupyterlab-spreadsheet

# Install vscode
ARG VSCODE_VERSION=4.17.0
ARG VSCODE_SHA=a256654aae171699f4dd869dd7f02588ff60411d6a88e95a3e8d997d72efe378
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
    && mkdir -p $CS_TEMP_HOME/Machine \
    && \ 
    # Manage extensions
    code-server --install-extension ms-python.python@2023.12.0 && \
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

RUN pip install \
    'git+https://github.com/betatim/vscode-binder' && \
    # jupyter_contrib_nbextensions likes to be installed with pip
    mamba install --quiet --yes -c plotly -c conda-forge \
    'jupyter_contrib_nbextensions' \ 
    'jupyter-dash' \
    'plotly' \
    'ipywidgets' \
    'markupsafe' \
    'ipympl' \
    'jupyter-server-proxy' \
    'jupyterlab-language-pack-fr-fr' \
    'jupyterlab_execute_time' \
    'nb_conda_kernels' \
    'jupyterlab-lsp' \
    'jupyter-lsp'  && \
    jupyter server extension enable --py jupyter_server_proxy && \
    jupyter nbextension enable codefolding/main --sys-prefix && \
    jupyter labextension enable \
      '@jupyterlab/translation-extension' \
      '@jupyterlab/server-proxy' \
      'nbdime-jupyterlab' \
    && \
    jupyter lab build && \
    jupyter lab clean && \
  clean-layer.sh && \
  rm -rf /home/$NB_USER/.cache/yarn && \
  rm -rf /home/$NB_USER/.node-gyp && \
  fix-permissions $CONDA_DIR && \
  fix-permissions /home/$NB_USER

# Update and pin packages
# See https://github.com/StatCan/aaw-kubeflow-containers/issues/293

# Install python, R, Julia and other useful language servers
RUN julia -e 'using Pkg; Pkg.add("LanguageServer")' && \
    /opt/conda/bin/R --silent --slave --no-save --no-restore -e 'install.packages("languageserver", repos="https://cran.r-project.org/")' && \
    mamba install -c conda-forge \
      'r-languageserver' \
      'python-lsp-server' \
    && \
# These should probably go in a package.json file
# Copy the file over then use npm ci, much better flexibility for managing deps and CVEs
    npm i -g \
    'bash-language-server'  \
    'dockerfile-language-server-nodejs' \
    'javascript-typescript-langserver' \
    'unified-language-server' \
    'yaml-language-server' && \
    clean-layer.sh && \ 
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# OpenM install
# Install OpenM++ MPI
ARG OMPP_VERSION="1.15.5"
# IMPORTANT: Don't forget to update the version number in the openmpp.desktop file!!
ARG OMPP_PKG_DATE="20231005"
ARG SHA256ompp=6d44076e1890c2e2ffb431182b9565cb4715830a027b01aafb9531e274bb8e84
# OpenM++ environment settings
ENV OMPP_INSTALL_DIR=/opt/openmpp/${OMPP_VERSION}

# OpenM++ expects sqlite to be installed (not just libsqlite)
RUN apt-get update --yes \
    && apt-get install --yes sqlite3 \
    && wget -q https://github.com/openmpp/main/releases/download/v${OMPP_VERSION}/openmpp_debian_${OMPP_PKG_DATE}.tar.gz -O /tmp/ompp.tar.gz \
    && echo "${SHA256ompp} /tmp/ompp.tar.gz" | sha256sum -c - \
    && mkdir -p ${OMPP_INSTALL_DIR} \
    && tar -xf /tmp/ompp.tar.gz -C ${OMPP_INSTALL_DIR} --strip-components=1
    
# Customize and rebuild omp-ui for jupyter-ompp-proxy install
# issue with making a relative publicPath https://github.com/quasarframework/quasar/issues/8513
ARG NODE_OPTIONS=--openssl-legacy-provider
RUN sed -i -e 's/history/hash/' ${OMPP_INSTALL_DIR}/ompp-ui/quasar.conf.js \
    && sed -i -e "s/OMS_URL:.*''/OMS_URL: '.'/" ${OMPP_INSTALL_DIR}/ompp-ui/quasar.conf.js \
    && npm install --prefix ${OMPP_INSTALL_DIR}/ompp-ui @babel/traverse@7.23.2\
    && npm run build --prefix ${OMPP_INSTALL_DIR}/ompp-ui \
    && rm -r ${OMPP_INSTALL_DIR}/html \
    && mv ${OMPP_INSTALL_DIR}/ompp-ui/dist/spa ${OMPP_INSTALL_DIR}/html \
    && fix-permissions ${OMPP_INSTALL_DIR}

COPY jupyter-ompp-proxy/ /opt/jupyter-ompp-proxy/
RUN pip install /opt/jupyter-ompp-proxy/

# Solarized Theme and Cell Execution Time
COPY jupyterlab-overrides.json /opt/conda/share/jupyter/lab/settings/overrides.json

ENV DEFAULT_JUPYTER_URL=/lab
ENV GIT_EXAMPLE_NOTEBOOKS=https://github.com/StatCan/aaw-contrib-jupyter-notebooks

###############################
###  docker-bits/7_remove_vulnerabilities.Dockerfile
###############################

# Remove libpdfbox-java due to CVE-2019-0228. See https://github.com/StatCan/aaw-kubeflow-containers/issues/249#issuecomment-834808115 for details.
# Issue opened https://github.com/jupyter/docker-stacks/issues/1299.
# This line of code should be removed once a solution or better alternative is found.
USER root
RUN apt-get update --yes \
    && dpkg -r --force-depends libpdfbox-java \
    && rm -rf /var/lib/apt/lists/*

# Forcibly upgrade packages to patch vulnerabilities
# See https://github.com/StatCan/aaw-private/issues/58#issuecomment-1471863092 for more details.
RUN pip3 --no-cache-dir install --quiet \
      'wheel==0.40.0' \
      'setuptools==67.6.0' \
      'pyjwt==2.6.0' \
      'oauthlib==3.2.2' \
      'mpmath==1.3.0' \
      'lxml==4.9.2' \
      && fix-permissions $CONDA_DIR && \
      fix-permissions /home/$NB_USER

USER $NB_USER

###############################
###  docker-bits/8_platform.Dockerfile
###############################

USER root

# Install AMD AOCL
ARG AOCL_VERSION=4.0
ENV AOCL_PATH=/opt/amd/aocl/${AOCL_VERSION}
ARG AOCL_SHA256=8a249e727beb8005639b4887074e1ea75020267ed1ac25520876a7ad21d0f4f6
RUN cd ${RESOURCES_PATH} && \
    wget --quiet https://download.amd.com/developer/eula/aocl/aocl-4-0/aocl-linux-aocc-${AOCL_VERSION}.tar.gz -O /tmp/aocl-linux-aocc-${AOCL_VERSION}.tar && \
    echo "${AOCL_SHA256} /tmp/aocl-linux-aocc-${AOCL_VERSION}.tar" | sha256sum -c - && \
    tar xf /tmp/aocl-linux-aocc-${AOCL_VERSION}.tar -C ./ && \
    cd ./aocl-linux-aocc-${AOCL_VERSION} && \
    /bin/bash ./install.sh -t /opt/amd/aocl && \
    cp setenv_aocl.sh ${AOCL_PATH} &&\
    rm /tmp/aocl-linux-aocc-${AOCL_VERSION}.tar

# Install AMD AOCC
ARG AOCC_VERSION=4.0.0
ARG AOCC_SHA256=2729ec524cbc927618e479994330eeb72df5947e90cfcc49434009eee29bf7d4
RUN cd ${RESOURCES_PATH} && \
   wget --quiet https://download.amd.com/developer/eula/aocc-compiler/aocc-compiler-${AOCC_VERSION}.tar -O /tmp/aocc-compiler-${AOCC_VERSION}.tar && \
   echo "${AOCC_SHA256} /tmp/aocc-compiler-${AOCC_VERSION}.tar" | sha256sum -c - && \
   tar xf /tmp/aocc-compiler-${AOCC_VERSION}.tar -C ./ && \
   cd ./aocc-compiler-${AOCC_VERSION} && \
   /bin/bash ./install.sh && \
   rm /tmp/aocc-compiler-${AOCC_VERSION}.tar

###############################
###  docker-bits/∞_CMD.Dockerfile
###############################

# Configure container startup

USER root
WORKDIR /home/$NB_USER
EXPOSE 8888
COPY start-custom.sh /usr/local/bin/
COPY mc-tenant-wrapper.sh /usr/local/bin/mc
COPY trino-wrapper.sh /usr/local/bin/trino
COPY start-oms.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/start-oms.sh

# Add --user to all pip install calls and point pip to Artifactory repository
COPY pip.conf /tmp/pip.conf
RUN cat /tmp/pip.conf >> /etc/pip.conf && rm /tmp/pip.conf

# Point R to Artifactory repository
COPY Rprofile.site /tmp/Rprofile.site
RUN cat /tmp/Rprofile.site >> /opt/conda/lib/R/etc/Rprofile.site && rm /tmp/Rprofile.site

# Add .Rprofile to /tmp so we can install it in start-custom.sh
COPY .Rprofile /tmp/.Rprofile

# Point conda to Artifactory repository
RUN conda config --add channels http://jfrog-platform-artifactory.jfrog-system:8081/artifactory/api/conda/conda-forge-remote --system && \
    conda config --remove channels conda-forge --system && \
    conda config --add channels http://jfrog-platform-artifactory.jfrog-system:8081/artifactory/api/conda/conda-forge-nvidia --system && \
    conda config --add channels http://jfrog-platform-artifactory.jfrog-system:8081/artifactory/api/conda/conda-pytorch-remote --system

USER $NB_USER
ENTRYPOINT ["tini", "--"]
CMD ["start-custom.sh"]
