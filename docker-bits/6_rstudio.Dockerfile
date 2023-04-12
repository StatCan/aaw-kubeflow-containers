# install rstudio-server
ARG RSTUDIO_VERSION=2022.07.2-576
ARG SHA256=6dc6a71c7a4805e347ab88d9d9574f8898191dfd0bc3191940ee3096ff47fbcd
RUN apt-get update && \
    apt install -y --no-install-recommends software-properties-common dirmngr && \
    wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc && \
    add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu jammy-cran40/" && \
    apt install -y --no-install-recommends r-base r-base-core r-recommended r-base-dev && \
    apt-get update && apt-get -y dist-upgrade

#install libssl1.1 dependency for rstudio-server on ubuntu 22.04
RUN wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb && \
    sudo dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb

RUN curl --silent -L  --fail "https://download2.rstudio.org/server/bionic/amd64/rstudio-server-${RSTUDIO_VERSION}-amd64.deb" > /tmp/rstudio.deb && \
    echo "${SHA256} /tmp/rstudio.deb" | sha256sum -c - && \
    apt-get install --no-install-recommends -y /tmp/rstudio.deb && \
    rm /tmp/rstudio.deb && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    #Harden rstudio-server
    echo "www-frame-origin=none" >> /etc/rstudio/rserver.conf && \
    echo "www-enable-origin-check=1" >> /etc/rstudio/rserver.conf && \
    echo "www-same-site=lax" >> /etc/rstudio/rserver.conf && \
    echo "restrict-directory-view=1" >> /etc/rstudio/rsession.conf
ENV PATH=$PATH:/usr/lib/rstudio-server/bin

COPY .Rprofile /home/$NB_USER

# Install some default R packages
RUN conda install --quiet --yes \
      'r-rodbc==1.3_20' \
      'r-tidymodels==1.0.0' \
      'r-arrow==10.0.1' \
      'r-aws.s3==0.3.22' \
      'r-catools==1.18.2' \
      'r-hdf5r==1.3.8' \
      'r-odbc==1.3.4' \
      'r-sf==1.0_7' \
      'r-e1071==1.7_13' \
    && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

RUN python3 -m pip install \
      'jupyter-rsession-proxy==2.1.0' \
      'jupyter-shiny-proxy==1.1' && \
      fix-permissions $CONDA_DIR && \
      fix-permissions /home/$NB_USER

# If using the docker bit in other Dockerfiles, this must get written over in a later layer
ENV DEFAULT_JUPYTER_URL="/rstudio"
ENV GIT_EXAMPLE_NOTEBOOKS=https://github.com/StatCan/aaw-contrib-r-notebooks.git
