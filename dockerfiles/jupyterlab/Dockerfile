ARG BASE_VERSION=2023-12-25
FROM quay.io/jupyter/datascience-notebook:$BASE_VERSION

ENV DEFAULT_JUPYTER_URL=/lab 

ARG NB_USER="jovyan"
ARG NB_UID="1000"
ARG NB_GID="100"

ENV NB_USER="${NB_USER}" \
    NB_UID=${NB_UID} \
    NB_GID=${NB_GID} \
    CONDA_DIR=/opt/conda \
    PATH=$PATH:/opt/conda/bin \
    NB_USER="jovyan" \
    HOME="/home/${NB_USER}"

# If using the docker bit in other Dockerfiles, this must get written over in a later layer
ENV GIT_EXAMPLE_NOTEBOOKS=https://gitlab.k8s.cloud.statcan.ca/business-transformation/aaw/aaw-contrib-jupyter-notebooks

ENV CS_DISABLE_FILE_DOWNLOADS=1
ENV CS_TEMP_HOME=/etc/share/code-server
ENV CS_DEFAULT_HOME=$HOME/.local/share/code-server
ENV SERVICE_URL=https://extensions.coder.com/api

ENV PATH="/home/jovyan/.local/bin/:${PATH}"
ENV PATH=$PATH:/usr/lib/rstudio-server/bin

ARG KUBECTL_VERSION=v1.15.10
ARG KUBECTL_URL=https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl
ARG KUBECTL_SHA=38a0f73464f1c39ca383fd43196f84bdbe6e553fe3e677b6e7012ef7ad5eaf2b

ARG AZCLI_URL=https://aka.ms/InstallAzureCLIDeb

ARG TRINO_URL=https://repo1.maven.org/maven2/io/trino/trino-cli/410/trino-cli-410-executable.jar
ARG TRINO_SHA=f32c257b9cfc38e15e8c0b01292ae1f11bda2b23b5ce1b75332e108ca7bf2e9b

ARG ARGO_CLI_VERSION=v3.4.5
ARG ARGO_CLI_URL=https://github.com/argoproj/argo-workflows/releases/download/${ARGO_CLI_VERSION}/argo-linux-amd64.gz
ARG ARGO_CLI_SHA=0528ff0c0aa87a3f150376eee2f1b26e8b41eb96578c43d715c906304627d3a1 

ARG VSCODE_VERSION=4.17.0
ARG VSCODE_SHA=a256654aae171699f4dd869dd7f02588ff60411d6a88e95a3e8d997d72efe378
ARG VSCODE_URL=https://github.com/coder/code-server/releases/download/v${VSCODE_VERSION}/code-server_${VSCODE_VERSION}_amd64.deb

ARG QUARTO_VERSION=1.4.176
ARG QUARTO_SHA=c06edd8930903a1018a27eb9f70fb9037b28a3cd8a7eb6299e8136876b4e11b3
ARG QUARTO_URL=https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.tar.gz

ARG RSTUDIO_VERSION=2023.12.0-369
ARG RSTUDIO_SHA256=452804d61bfee2996d98d1c406b31d93e03e58df2a34996b821925ce0c04ffe8

# Install OpenM++ MPI
ARG OMPP_VERSION="1.15.6"
# IMPORTANT: Don't forget to update the version number in the openmpp.desktop file!!
ARG OMPP_PKG_DATE="20231115"
ARG SHA256ompp=ad8027e2097ed46205fe0e89c1008680e92c5de36af2613d0af8070e5c78b903
# OpenM++ environment settings
ENV OMPP_INSTALL_DIR=/opt/openmpp/${OMPP_VERSION}

# ---

USER root
COPY clean-layer.sh /usr/bin/clean-layer.sh
RUN chmod +x /usr/bin/clean-layer.sh

RUN apt-get update && apt-get install -y --no-install-recommends \
    # alien is for installing RPM packages, not sure if we need this
    alien \
    # byobu is a terminal multiplexer, not sure if we need this
    byobu \
    curl \
    dirmngr \
    dos2unix \
    gdebi-core \
    htop \
    jq \
    language-pack-fr \
    less \
    libarchive-tools \
    libmagic1 \
    libpng-dev \
    libwebp7 \
    libxmu6 \
    nginx \
    numactl \
    openjdk-8-jre \
    openssl \
    openmpi-bin \
    libopenmpi-dev \
    ranger \
    software-properties-common \
    tar \
    tig \
    tmux \
    tree \
    unixodbc \
    unixodbc-dev \
    vim \
    wget \
    zip && \
    rm -rf /var/lib/apt/lists/* && \
    /usr/bin/clean_layer.sh

RUN pip3 --no-cache-dir install --quiet \
      cryptography==41.0.6 \
      fire \
      git+https://github.com/betatim/vscode-binder \
      git+https://github.com/zachomedia/s3fs@8aa929f78666ff9e323cde7d9be9262db5a17985 \
      joblib \
      # JupyterLab Stuff
      jupyter_contrib_nbextensions \
      dash \
      jupyter-lsp \
      jupyter-rsession-proxy==2.2.0 \
      jupyter-server-proxy \
      jupyter-shiny-proxy \
      jupyterlab_execute_time \
      jupyterlab-language-pack-fr-FR \
      jupyterlab-lsp \
      # kubeflow-mpi \
      kubeflow-pytorchjob \
      kubeflow-tfjob \
      kubeflow-training \
      lxml \
      markupsafe \
      # maybe we can remove minio?
      minio \
      mpmath \
      oauthlib \
      pexpect==4.9.0 \
      pillow \
      pyarrow \
      pyjwt \
      pyodbc \
      pyyaml \
      setuptools \
      wheel && \
      fix-permissions /home/$NB_USER

# Install some packages from Anaconda using Mamba
RUN mamba install --quiet --yes \
      'r-arrow' \
      'r-aws.s3' \
      'r-catools' \
      'r-hdf5r' \
      'r-odbc' \
      'r-sf' \
      'r-markdown' \
      'r-languageserver' \
      'nb_conda_kernels' \
      'python-lsp-server' && \
    clean-layer.sh && \ 
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

COPY aaw-suspend-server.sh /usr/local/bin
RUN chmod +x /usr/local/bin/aaw-suspend-server.sh

# --- CLI Stuff

# maybe we can remove this minio stuff?
# MinIO Client install
COPY --from=minio/mc:RELEASE.2024-03-09T06-43-06Z /bin/mc /usr/local/bin/mc-original

# Add helpers for shell initialization
COPY shell_helpers.sh /tmp/shell_helpers.sh

RUN \ 
    # kubectl
    curl -LO "${KUBECTL_URL}" \
    && echo "${KUBECTL_SHA} kubectl" | sha256sum -c - \
    && chmod +x ./kubectl \
    && sudo mv ./kubectl /usr/local/bin/kubectl \
  && \
    # AzureCLI
    curl -sLO "${AZCLI_URL}" \
    && bash InstallAzureCLIDeb \
    && rm InstallAzureCLIDeb \
    && echo "azcli: ok" \
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

# --- JupyterLab Stuff

USER root
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

RUN jupyter server extension enable --py jupyter_server_proxy && \
    # commenting out since we are using jupyter notebook 7 which is incompatible with nbextension
    #jupyter nbextension enable codefolding/main --sys-prefix && \
    jupyter labextension enable \
      '@jupyterlab/translation-extension' \
      '@jupyterlab/server-proxy' \
      'nbdime-jupyterlab' \
    && \
    jupyter lab build && \
    jupyter lab clean && \
  npm cache clean --force && \
  rm -rf /home/$NB_USER/.cache/yarn && \
  rm -rf /home/$NB_USER/.node-gyp && \
  fix-permissions $CONDA_DIR && \
  fix-permissions /home/$NB_USER

# Install Julia language server
RUN julia -e 'using Pkg; Pkg.add("LanguageServer")'

# Install other langauge servers
RUN npm i -g \
    'bash-language-server'  \
    'dockerfile-language-server-nodejs' \
    'javascript-typescript-langserver' \
    'unified-language-server' \
    'yaml-language-server' && \
    fix-permissions /home/$NB_USER

# OpenM install

COPY jupyter-ompp-proxy/ /opt/jupyter-ompp-proxy/

# OpenM++ expects sqlite to be installed (not just libsqlite)
# Customize and rebuild omp-ui for jupyter-ompp-proxy install
# issue with making a relative publicPath https://github.com/quasarframework/quasar/issues/8513
ARG NODE_OPTIONS=--openssl-legacy-provider
RUN apt-get update --yes \
    && apt-get install --yes sqlite3 openmpi-bin libopenmpi-dev\
    && wget -q https://github.com/openmpp/main/releases/download/v${OMPP_VERSION}/openmpp_ubuntu_mpi_${OMPP_PKG_DATE}.tar.gz -O /tmp/ompp.tar.gz \
    && echo "${SHA256ompp} /tmp/ompp.tar.gz" | sha256sum -c - \
    && mkdir -p ${OMPP_INSTALL_DIR} \
    && tar -xf /tmp/ompp.tar.gz -C ${OMPP_INSTALL_DIR} --strip-components=1\
    && rm -f /tmp/ompp.tar.gz \
# Customize and rebuild omp-ui for jupyter-ompp-proxy install
# issue with making a relative publicPath https://github.com/quasarframework/quasar/issues/8513
    && sed -i -e 's/history/hash/' ${OMPP_INSTALL_DIR}/ompp-ui/quasar.conf.js \
    && sed -i -e "s/OMS_URL:.*''/OMS_URL: '.'/" ${OMPP_INSTALL_DIR}/ompp-ui/quasar.conf.js \
    && npm install --prefix ${OMPP_INSTALL_DIR}/ompp-ui @babel/traverse@7.23.2\
    && npm run build --prefix ${OMPP_INSTALL_DIR}/ompp-ui \
    && rm -r ${OMPP_INSTALL_DIR}/html \
    && mv ${OMPP_INSTALL_DIR}/ompp-ui/dist/spa ${OMPP_INSTALL_DIR}/html \
    && fix-permissions ${OMPP_INSTALL_DIR} \
    && pip install /opt/jupyter-ompp-proxy/

# Solarized Theme and Cell Execution Time
COPY jupyterlab-overrides.json /opt/conda/share/jupyter/lab/settings/overrides.json

# -- RStudio Server

RUN curl --silent -L --fail "https://download2.rstudio.org/server/jammy/amd64/rstudio-server-${RSTUDIO_VERSION}-amd64.deb" > /tmp/rstudio.deb && \
    echo "${RSTUDIO_SHA256} /tmp/rstudio.deb" | sha256sum -c - && \
    apt-get install --no-install-recommends -y /tmp/rstudio.deb && \
    rm /tmp/rstudio.deb && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    # Harden rstudio-server
    echo "www-frame-origin=none" >> /etc/rstudio/rserver.conf && \
    echo "www-enable-origin-check=1" >> /etc/rstudio/rserver.conf && \
    echo "www-same-site=lax" >> /etc/rstudio/rserver.conf && \
    echo "restrict-directory-view=1" >> /etc/rstudio/rsession.conf && \
    # https://github.com/rstudio/rstudio/issues/14060
    echo "rsession-ld-library-path=/opt/conda/lib" >> /etc/rstudio/rserver.conf 

RUN wget -q ${QUARTO_URL} -O /tmp/quarto-${QUARTO_VERSION}-linux-amd64.tar.gz && \
    echo "${QUARTO_SHA} /tmp/quarto-${QUARTO_VERSION}-linux-amd64.tar.gz" | sha256sum -c - && \
    tar -xzvf /tmp/quarto-${QUARTO_VERSION}-linux-amd64.tar.gz -C /tmp/ && \
    chmod +x /tmp/quarto-${QUARTO_VERSION} && \
    ln -s /tmp/quarto-${QUARTO_VERSION}/bin/quarto /usr/bin/quarto
    
# --- Remove Vulnerabilities

# Remove libpdfbox-java due to CVE-2019-0228. See https://github.com/StatCan/aaw-kubeflow-containers/issues/249#issuecomment-834808115 for details.
# Issue opened https://github.com/jupyter/docker-stacks/issues/1299.
# This line of code should be removed once a solution or better alternative is found.
USER root
RUN dpkg -r --force-depends libpdfbox-java \
    && rm -rf /var/lib/apt/lists/*

# --- ∞_CMD

# Configure container startup

USER root
WORKDIR /home/$NB_USER
EXPOSE 8888
COPY start-custom.sh /usr/local/bin/
# we may want to remove this mc (minio)
COPY mc-tenant-wrapper.sh /usr/local/bin/mc
COPY trino-wrapper.sh /usr/local/bin/trino

# Add --user to all pip install calls and point pip to Artifactory repository
COPY pip.conf /tmp/pip.conf
RUN cat /tmp/pip.conf >> /etc/pip.conf && rm /tmp/pip.conf \
    && pip config set global.timeout 300

# Point R to Artifactory repository
COPY Rprofile.site /tmp/Rprofile.site
RUN cat /tmp/Rprofile.site >> /opt/conda/lib/R/etc/Rprofile.site && rm /tmp/Rprofile.site

# Add .Rprofile to /tmp so we can install it in start-custom.sh
COPY .Rprofile /tmp/.Rprofile

# Copy over Instructions to Home directory
ADD connect-to-filer.md /home/$NB_USER/connect-to-filer.md

# Point mamba to Artifactory repository
RUN mamba config --add channels http://jfrog-platform-artifactory.jfrog-system:8081/artifactory/api/conda/conda-forge-remote --system && \
    mamba config --remove channels conda-forge --system && \
    mamba config --add channels http://jfrog-platform-artifactory.jfrog-system:8081/artifactory/api/conda/conda-forge-nvidia --system && \
    mamba config --add channels http://jfrog-platform-artifactory.jfrog-system:8081/artifactory/api/conda/conda-pytorch-remote --system

USER $NB_USER
ENTRYPOINT ["tini", "--"]
CMD ["start-custom.sh"]
