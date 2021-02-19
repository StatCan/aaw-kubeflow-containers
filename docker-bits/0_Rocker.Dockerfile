FROM rocker/geospatial:4.0.3

# For compatibility with docker stacks
ARG NB_USER="jovyan"
ARG HOME=/home/$NB_USER
ARG NB_UID="1000"
ARG NB_GID="100"

# RUN userdel rstudio \
#     && useradd jovyan -s /sbin/nologin -u $NB_UID -g $NB_GID

USER root
ENV PATH="/home/jovyan/.local/bin/:${PATH}"

RUN apt-get update --yes \
    && apt-get install --yes python3-pip tini language-pack-fr \
    && rm -rf /var/lib/apt/lists/*

RUN /rocker_scripts/install_shiny_server.sh \
    && pip3 install jupyter \
    && rm -rf /var/lib/apt/lists/*
