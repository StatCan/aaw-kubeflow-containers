# install rstudio-server
ARG RSTUDIO_VERSION=2024.04.2-764
ARG SHA256=d8ffb8e5c2dadb1c74df037c291a5585e595d978b3aec48a4a94a970e04a947d
RUN apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common dirmngr gdebi-core && \
    wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc && \
    add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu jammy-cran40/" && \
    apt-get install -y --no-install-recommends r-base r-base-core r-recommended r-base-dev && \
    apt-get -y upgrade
RUN curl --silent -L  --fail "https://s3.amazonaws.com/rstudio-ide-build/server/jammy/amd64/rstudio-server-${RSTUDIO_VERSION}-amd64.deb" > /tmp/rstudio.deb && \
    echo "${SHA256} /tmp/rstudio.deb" | sha256sum -c - && \
    apt-get install --no-install-recommends -y /tmp/rstudio.deb && \
    rm /tmp/rstudio.deb && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Harden rstudio-server
RUN mkdir -p /etc/rstudio && \
    echo "www-frame-origin=none" >> /etc/rstudio/rserver.conf && \
    echo "www-enable-origin-check=1" >> /etc/rstudio/rserver.conf && \
    echo "www-same-site=lax" >> /etc/rstudio/rserver.conf && \
    echo "restrict-directory-view=1" >> /etc/rstudio/rsession.conf && \
    # https://github.com/rstudio/rstudio/issues/14060
    echo "rsession-ld-library-path=/opt/conda/lib" >> /etc/rstudio/rserver.conf 

ENV PATH=$PATH:/usr/lib/rstudio-server/bin

RUN conda install --quiet --yes \
      'r-rodbc' \
      'r-tidyverse' \
      'r-arrow' \
      'r-aws.s3' \
      'r-catools' \
      'r-odbc' \
      'r-hdf5r' \
      'r-sf' \
      'r-e1071' \
      'r-markdown' \
    && \
    clean-layer.sh && \
    fix-permissions "$CONDA_DIR" && \
    fix-permissions "/home/$NB_USER"

RUN python3 -m pip install --no-cache-dir \
      'jupyter-rsession-proxy==2.2.0' \
      'jupyter-server-proxy==4.2.0' \
      'jupyter-shiny-proxy==1.1' && \
      fix-permissions "$CONDA_DIR" && \
      fix-permissions "/home/$NB_USER"

# If using the docker bit in other Dockerfiles, this must get written over in a later layer
ENV DEFAULT_JUPYTER_URL="/rstudio"
ENV GIT_EXAMPLE_NOTEBOOKS=https://github.com/StatCan/aaw-contrib-r-notebooks.git
