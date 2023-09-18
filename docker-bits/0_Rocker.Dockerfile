# Rocker/geospatial is tagged by R version number.  They are not clear on whether they'll change those tagged
# images for hotfixes, so always pin tag and digest to prevent unexpected upstream changes

FROM rocker/geospatial:4.2.1@sha256:5caca36b8962233f8636540b7c349d3f493f09e864b6e278cb46946ccf60d4d2

# For compatibility with docker stacks
ARG NB_USER="jovyan"
ARG HOME=/home/$NB_USER
ENV NB_UID="1000"
ENV NB_GID="100"

USER root
ENV PATH="/home/jovyan/.local/bin/:${PATH}"

#Fix-permissions
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
