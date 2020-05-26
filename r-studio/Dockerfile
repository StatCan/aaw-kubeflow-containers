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
      'r-dplyr' \
      'r-ggplot2' \
      'r-hdf5r' \
      'r-jsonlite' \
      'r-rstan' \
      'r-sf' \
      'r-shiny' \
      'r-rmarkdown' \
      'r-sparklyr' \
      'r-tidyr' \
      'r-odbc' \
      'r-devtools' \
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


# kubectl, mc, az, pachctl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl \
    && chmod +x ./kubectl \
    && sudo mv ./kubectl /usr/local/bin/kubectl \
  && \
    wget https://dl.min.io/client/mc/release/linux-amd64/mc \
    && chmod +x mc \
    && mv mc /usr/local/bin/mc \
  && \
    sh -c 'curl -sL https://aka.ms/InstallAzureCLIDeb | bash' \
  && \
    curl -o /tmp/pachctl.deb -L \
      https://github.com/pachyderm/pachyderm/releases/download/v1.10.0/pachctl_1.10.0_amd64.deb \
    && sudo dpkg -i /tmp/pachctl.deb


# We'll replace this once the git repo is created.
COPY R-notebooks /home/$NB_USER/examples


COPY start-custom.sh /usr/local/bin
ENV DEFAULT_JUPYTER_URL="/rstudio"
WORKDIR /home/$NB_USER
EXPOSE 8888
USER $NB_USER
ENTRYPOINT ["tini", "--"]
CMD ["start-custom.sh"]
