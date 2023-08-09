# Rocker/geospatial is tagged by R version number.  They are not clear on whether they'll change those tagged
# images for hotfixes, so always pin tag and digest to prevent unexpected upstream changes
FROM rocker/geospatial:dev-osgeo@sha256:17a7181bdfa3cdb291340d4f47469715e5e2c30ba31f35419e8b0676cacd72cd

# For compatibility with docker stacks
ARG NB_USER="jovyan"
ARG HOME=/home/$NB_USER
ENV NB_UID="1000"
ENV NB_GID="100"

USER root
ENV PATH="/home/jovyan/.local/bin/:${PATH}"

# Fix Permissions
COPY remote-desktop/fix-permissions /usr/bin/fix-permissions
RUN chmod u+x /usr/bin/fix-permissions

RUN apt-get update --yes \
    && apt-get install --yes python3-pip tini language-pack-fr \
    && rm -rf /var/lib/apt/lists/*

RUN /rocker_scripts/install_shiny_server.sh \
    && pip3 install jupyter \
    && rm -rf /var/lib/apt/lists/* 

# Users should install R packages in their home directory
RUN chmod 555 /usr/local/lib/R /usr/local/lib/R/site-library/
