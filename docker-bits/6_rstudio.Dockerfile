# install rstudio-server
ARG RSTUDIO_VERSION=2022.07.2-576
ARG SHA256=6dc6a71c7a4805e347ab88d9d9574f8898191dfd0bc3191940ee3096ff47fbcd
RUN apt-get update && \
    curl --silent -L  --fail "https://download2.rstudio.org/server/bionic/amd64/rstudio-server-${RSTUDIO_VERSION}-amd64.deb" > /tmp/rstudio.deb && \
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

# Install some default R packages
RUN conda install --quiet --yes \
      'r-rodbc==1.3_19' \
      'r-tidymodels==1.0.0' \
      'r-arrow==9.0.0' \
      'r-aws.s3==0.3.21' \
      'r-catools==1.18.2' \
      'r-hdf5r==1.3.3' \
      'r-odbc==1.3.3' \
      'r-sf==1.0_4' \
      'r-e1071==1.7_8' \
    && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

RUN python3 -m pip install \
      'git+https://github.com/blairdrummond/jupyter-rsession-proxy#egg=jupyter-rsession-proxy' \
      'jupyter-shiny-proxy==1.1' && \
      fix-permissions $CONDA_DIR && \
      fix-permissions /home/$NB_USER

RUN chown $NB_USER:users /var/lib/rstudio-server/rstudio.sqlite

ENV DEFAULT_JUPYTER_URL="/rstudio"
ENV GIT_EXAMPLE_NOTEBOOKS=https://github.com/StatCan/aaw-contrib-r-notebooks.git
