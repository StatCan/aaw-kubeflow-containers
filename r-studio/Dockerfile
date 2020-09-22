FROM k8scc01covidacr.azurecr.io/minimal-notebook-cpu:master
USER root

# install rstudio-server
ARG RSTUDIO_VERSION=1.1.463
ARG SHA256=62aafd46f79705ca5db9c629ce3b60bf708d81c06a6b86cc4b417fbaf30691c1
RUN apt-get update && \
    wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl1.0/libssl1.0.0_1.0.2n-1ubuntu5.4_amd64.deb -O libssl1.0.0.deb && \
    dpkg -i libssl1.0.0.deb && \
    curl --silent -L --fail "https://download2.rstudio.org/rstudio-server-${RSTUDIO_VERSION}-amd64.deb" > /tmp/rstudio.deb && \
    echo "${SHA256} /tmp/rstudio.deb" | sha256sum -c - && \
    apt-get install --no-install-recommends -y /tmp/rstudio.deb && \
    rm /tmp/rstudio.deb && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
ENV PATH=$PATH:/usr/lib/rstudio-server/bin

# Install some default R packages
RUN python3 -m pip install \
      'jupyter-server-proxy==1.5.0' \
      'jupyter-rsession-proxy==1.2' \
      'jupyter-shiny-proxy==1.1' && \
    conda install --quiet --yes \   
      'r-base==3.6.3' \
      'r-caret==6.0_86' \
      'r-crayon==1.3.4' \
      'r-devtools==2.3.1' \
      'r-forecast==8.13' \
      'r-hexbin==1.28.1' \
      'r-htmltools==0.5.0' \
      'r-htmlwidgets==1.5.1' \
      'r-irkernel==1.1.1' \
      'r-nycflights13==1.0.1' \
      'r-randomforest==4.6_14' \
      'r-rcurl==1.98_1.2' \
      'r-rmarkdown==2.3' \
      'r-rodbc==1.3_16' \
      'r-rsqlite==2.2.0' \
      'r-shiny==1.5.0' \
      'r-tidyverse==1.3.0' \
      'r-tidymodels==0.1.0' \
      'r-arrow==0.17.1' \
      'r-aws.s3==0.3.21' \
      'r-catools==1.18.0' \
      'r-hdf5r==1.3.2' \
      'r-odbc==1.2.3' \
      'r-sf==0.9_5' \
      'r-sparklyr==1.4.0' \
    && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Install e1071 R package (dependency of the caret R package)
RUN conda install --quiet --yes r-e1071

# SQLite drivers
# The default /etc/odbcinst.ini file doesn't use full paths,
# and it was causing R to fail to load the drivers.
RUN apt-get update && apt-get install -y \
    libsqlite3-dev \
    libsqliteodbc \
    && apt-get clean && rm -rf /var/lib/apt/lists/* && \
    sed -i 's~^\(Setup\|Driver\)=\([^/]*\)$~\1=/usr/lib/x86_64-linux-gnu/odbc/\2~' /etc/odbcinst.ini && \
    sed -i 's~libsqliteodbc.so~libsqlite3odbc.so~' /etc/odbcinst.ini 

RUN apt-get clean 

COPY start-custom.sh /usr/local/bin
ENV DEFAULT_JUPYTER_URL="/rstudio"
WORKDIR /home/$NB_USER
EXPOSE 8888
USER $NB_USER
ENTRYPOINT ["tini", "--"]
CMD ["start-custom.sh"]
