# Rocker/geospatial is tagged by R version number.  They are not clear on whether they'll change those tagged 
# images for hotfixes, so always pin tag and digest to prevent unexpected upstream changes
FROM rocker/geospatial:4.0.3@sha256:9e00ab4fec7b38a0edbadb07e7554bf3b7fa34d15c6fe42522a09ae88d336219

# For compatibility with docker stacks
ARG NB_USER="jovyan"
ARG HOME=/home/$NB_USER
ARG NB_UID="1000"
ARG NB_GID="100"

USER root
ENV PATH="/home/jovyan/.local/bin/:${PATH}"

RUN apt-get update --yes \
    && apt-get install --yes python3-pip tini language-pack-fr \
    && rm -rf /var/lib/apt/lists/*

RUN /rocker_scripts/install_shiny_server.sh \
    && pip3 install jupyter \
    && rm -rf /var/lib/apt/lists/*
