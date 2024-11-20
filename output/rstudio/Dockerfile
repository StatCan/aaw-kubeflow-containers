
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

ARG BASE_VERSION=2024-06-17

FROM k8scc01covidacr.azurecr.io/sas4c:0.0.3 as SASHome
FROM quay.io/jupyter/datascience-notebook:$BASE_VERSION

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
COPY suspend-server.sh /usr/local/bin

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
      chmod +x /usr/local/bin/suspend-server.sh

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
      'pass' \
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
      # these are required by some r packages, adding these here so they get
      # installed into all images.
      'libfreetype6-dev' \
      'libpng-dev' \
      'libtiff5-dev' \
      'libjpeg-dev' \
      'libtiff-dev' \
      'libfreetype-dev' \
      'libfreetype6' && \
    rm -rf /var/lib/apt/lists/*


ARG KUBECTL_VERSION=v1.29.10
ARG KUBECTL_URL=https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl

ARG AZCLI_URL=https://aka.ms/InstallAzureCLIDeb

ARG OH_MY_ZSH_URL=https://raw.githubusercontent.com/loket/oh-my-zsh/feature/batch-mode/tools/install.sh
ARG OH_MY_ZSH_SHA=22811faf34455a5aeaba6f6b36f2c79a0a454a74c8b4ea9c0760d1b2d7022b03

ARG TRINO_URL=https://repo1.maven.org/maven2/io/trino/trino-cli/410/trino-cli-410-executable.jar
ARG TRINO_SHA=f32c257b9cfc38e15e8c0b01292ae1f11bda2b23b5ce1b75332e108ca7bf2e9b

ARG ARGO_CLI_VERSION=v3.5.12
ARG ARGO_CLI_URL=https://github.com/argoproj/argo-workflows/releases/download/${ARGO_CLI_VERSION}/argo-linux-amd64.gz
ARG ARGO_CLI_CHECKSUM_URL=https://github.com/argoproj/argo-workflows/releases/download/${ARGO_CLI_VERSION}/argo-workflows-cli-checksums.txt

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
    && curl -LO "${KUBECTL_URL}.sha256" \
    && echo "$(cat kubectl.sha256) kubectl" | sha256sum -c - \
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
    && curl -LO ${ARGO_CLI_CHECKSUM_URL} \
    && grep argo-linux-amd64.gz argo-workflows-cli-checksums.txt | sha256sum -c - \
    && gunzip argo-linux-amd64.gz \
    && chmod +x argo-linux-amd64 \
    && sudo mv ./argo-linux-amd64 /usr/local/bin/argo \
    && argo version

ARG GIT_CRED_MANAGER_VERSION=2.5.1
ARG GIT_CRED_MANAGER_URL=https://github.com/git-ecosystem/git-credential-manager/releases/download/v${GIT_CRED_MANAGER_VERSION}/gcm-linux_amd64.${GIT_CRED_MANAGER_VERSION}.deb
ARG GIT_CRED_MANAGER_SHA=03c7b174a6f90e1ae860980ba5fda4490f04e5b9aaa802e2d469e72ec5dae6a4

RUN wget -q "${GIT_CRED_MANAGER_URL}" -O ./gcm.deb \
  && echo "${GIT_CRED_MANAGER_SHA}  ./gcm.deb" | sha256sum -c - \
  && dpkg -i ./gcm.deb \
  && rm ./gcm.deb

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
###  docker-bits/6_rstudio-server.Dockerfile
###############################

# install rstudio-server
ARG RSTUDIO_VERSION=2024.04.2-764
ARG SHA256=d8ffb8e5c2dadb1c74df037c291a5585e595d978b3aec48a4a94a970e04a947d
RUN apt-get update && \
    apt install -y --no-install-recommends software-properties-common dirmngr gdebi-core && \
    wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc && \
    add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu jammy-cran40/" && \
    apt install -y --no-install-recommends r-base r-base-core r-recommended r-base-dev && \
    apt-get update && apt-get -y dist-upgrade

RUN curl --silent -L  --fail "https://s3.amazonaws.com/rstudio-ide-build/server/jammy/amd64/rstudio-server-${RSTUDIO_VERSION}-amd64.deb" > /tmp/rstudio.deb && \
    echo "${SHA256} /tmp/rstudio.deb" | sha256sum -c - && \
    apt-get install --no-install-recommends -y /tmp/rstudio.deb && \
    rm /tmp/rstudio.deb && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

###############################
###  docker-bits/6_rstudio.Dockerfile
###############################

# Harden rstudio-server
RUN mkdir -p /etc/rstudio && \
    echo "www-frame-origin=none" >> /etc/rstudio/rserver.conf && \
    echo "www-enable-origin-check=1" >> /etc/rstudio/rserver.conf && \
    echo "www-same-site=lax" >> /etc/rstudio/rserver.conf && \
    echo "restrict-directory-view=1" >> /etc/rstudio/rsession.conf && \
    # Sets the default working dir
    echo "session-default-working-dir=/home/jovyan/workspace" >> /etc/rstudio/rsession.conf && \
    echo "session-default-new-project-dir=/home/jovyan/workspace" >> /etc/rstudio/rsession.conf && \
    # https://github.com/rstudio/rstudio/issues/14060
    echo "rsession-ld-library-path=/opt/conda/lib" >> /etc/rstudio/rserver.conf 

ENV PATH=$PATH:/usr/lib/rstudio-server/bin

RUN mamba install --quiet --yes \
      'r-rodbc' \
      'r-tidyverse' \
      'r-arrow' \
      'r-aws.s3' \
      'r-catools' \
      && \
      clean-layer.sh && \
      fix-permissions $CONDA_DIR && \
      fix-permissions /home/$NB_USER
      
# Install some default R packages
RUN mamba install --quiet --yes \
      'r-hdf5r' \
      'r-odbc' \
      'r-sf' \
      'r-e1071' \
      'r-markdown' \
    && \
    clean-layer.sh && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

RUN python3 -m pip install \
      'jupyter-rsession-proxy==2.2.0' \
      'jupyter-server-proxy==4.2.0' && \
      fix-permissions $CONDA_DIR && \
      fix-permissions /home/$NB_USER

# If using the docker bit in other Dockerfiles, this must get written over in a later layer
ENV DEFAULT_JUPYTER_URL="/rstudio"
ENV GIT_EXAMPLE_NOTEBOOKS=https://gitlab.k8s.cloud.statcan.ca/business-transformation/aaw/aaw-contrib-r-notebooks.git

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
      'pyarrow==14.0.1' \
      'cryptography==41.0.6' \
      && fix-permissions $CONDA_DIR && \
      fix-permissions /home/$NB_USER

USER $NB_USER

###############################
###  docker-bits/∞_CMD.Dockerfile
###############################

# Configure container startup

USER root
WORKDIR /home/$NB_USER
EXPOSE 8888
COPY start-custom.sh start-oms.sh restart-oms.sh /usr/local/bin/
COPY trino-wrapper.sh /usr/local/bin/trino

RUN chmod +x /usr/local/bin/start-oms.sh && \
    chmod +x /usr/local/bin/restart-oms.sh

# Add --user to all pip install calls and point pip to Artifactory repository
COPY pip.conf /tmp/pip.conf
RUN cat /tmp/pip.conf >> /etc/pip.conf && rm /tmp/pip.conf

# Point R to Artifactory repository
#COPY Rprofile.site /tmp/Rprofile.site
#RUN cat /tmp/Rprofile.site >> /opt/conda/lib/R/etc/Rprofile.site && rm /tmp/Rprofile.site

# Add .Rprofile to /tmp so we can install it in start-custom.sh
COPY .Rprofile /tmp/.Rprofile

# Copy over Instructions to Home directory
ADD connect-to-filer.md /home/$NB_USER/connect-to-filer.md

# Point conda to Artifactory repository
RUN conda config --remove channels conda-forge --system

USER $NB_USER
ENTRYPOINT ["tini", "--"]
CMD ["start-custom.sh"]
