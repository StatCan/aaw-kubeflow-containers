FROM jupyter/r-notebook
USER root

# install rstudio-server
ARG RSTUDIO_VERSION=1.1.463
ARG SHA256=62aafd46f79705ca5db9c629ce3b60bf708d81c06a6b86cc4b417fbaf30691c1
RUN apt-get update && \
    curl --silent -L --fail "https://download2.rstudio.org/rstudio-server-${RSTUDIO_VERSION}-amd64.deb" > /tmp/rstudio.deb && \
    echo "${SHA256} /tmp/rstudio.deb" | sha256sum -c - && \
    apt-get install --no-install-recommends -y /tmp/rstudio.deb && \
    rm /tmp/rstudio.deb && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
ENV PATH=$PATH:/usr/lib/rstudio-server/bin

# Install some default R packages
RUN python3 -m pip install \
      'jupyter-server-proxy' \
      'jupyter-rsession-proxy' \
      'jupyter-shiny-proxy' && \
    conda install --quiet --yes \
      'r-arrow' \
      'r-aws.s3' \
      'r-catools' \
      'r-devtools' \
      'r-dplyr' \
      'r-ggplot2' \
      'r-hdf5r' \
      'r-jsonlite' \
      'r-odbc' \
      'r-rmarkdown' \
      'r-rstan' \
      'r-sf' \
      'r-shiny' \
      'r-sparklyr' \
      'r-tidyr' \
    && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER


# SQLite drivers
# The default /etc/odbcinst.ini file doesn't use full paths,
# and it was causing R to fail to load the drivers.
RUN apt-get update && apt-get install -y \
    libsqlite3-dev \
    libsqliteodbc \
    && apt-get clean && rm -rf /var/lib/apt/lists/* && \
    sed -i 's~^\(Setup\|Driver\)=\([^/]*\)$~\1=/usr/lib/x86_64-linux-gnu/odbc/\2~' /etc/odbcinst.ini && \
    sed -i 's~libsqliteodbc.so~libsqlite3odbc.so~' /etc/odbcinst.ini 


# Nice tools
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
    apt-get clean && rm -rf /var/lib/apt/lists/* 


ARG KUBECTL_VERSION=v1.15.10
ARG KUBECTL_URL=https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl
ARG KUBECTL_SHA=38a0f73464f1c39ca383fd43196f84bdbe6e553fe3e677b6e7012ef7ad5eaf2b

ARG MC_VERSION=mc.RELEASE.2020-06-20T00-18-43Z
ARG MC_URL=https://dl.min.io/client/mc/release/linux-amd64/${MC_VERSION}
ARG MC_SHA=7198b0634f84c27e656bba527bf80ed048087e99afc7744e0fdd9e0790a726f5

ARG AZCLI_URL=https://aka.ms/InstallAzureCLIDeb 
ARG AZCLI_SHA=c03302f47be07d02afe3edec63080c7806980c51709c016af2f27901d51417b4

ARG PACHCTL_VERSION=1.10.5
ARG PACHCTL_URL=https://github.com/pachyderm/pachyderm/releases/download/v${PACHCTL_VERSION}/pachctl_${PACHCTL_VERSION}_amd64.deb 
ARG PACHCTL_SHA=8bc58206e87c3c4304a074c1479e08bdf173743dd6869d0ad4e792830a0df5c5

# kubectl, mc, az, pachctl
RUN curl -LO "${KUBECTL_URL}" \
    && echo "${KUBECTL_SHA} kubectl" | sha256sum -c - \
    && chmod +x ./kubectl \
    && sudo mv ./kubectl /usr/local/bin/kubectl \
  && \
    wget --quiet -O mc "${MC_URL}" \
    && echo "${MC_SHA} mc" | sha256sum -c - \
    && chmod +x mc \
    && mv mc /usr/local/bin/mc \
  && \
    curl -sLO https://aka.ms/InstallAzureCLIDeb \
    && echo "${AZCLI_SHA} InstallAzureCLIDeb" | sha256sum -c - \
    && bash InstallAzureCLIDeb \
  && \
    curl -o /tmp/pachctl.deb -L "${PACHCTL_URL}" \
    && echo "${PACHCTL_SHA} /tmp/pachctl.deb" | sha256sum -c - \
    && sudo dpkg -i /tmp/pachctl.deb


COPY start-custom.sh /usr/local/bin
ENV DEFAULT_JUPYTER_URL="/rstudio"
WORKDIR /home/$NB_USER
EXPOSE 8888
USER $NB_USER
ENTRYPOINT ["tini", "--"]
CMD ["start-custom.sh"]
