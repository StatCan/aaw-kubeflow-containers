
###############################
###  docker-bits/0_Rocker.Dockerfile
###############################

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

###############################
###  docker-bits/3_Kubeflow.Dockerfile
###############################



###############################
###  docker-bits/4_CLI.Dockerfile
###############################



###############################
###  docker-bits/6_remote-desktop.Dockerfile
###############################



###############################
###  docker-bits/7_remove_vulnerabilities.Dockerfile
###############################



###############################
###  docker-bits/8_platform.Dockerfile
###############################



###############################
###  docker-bits/∞_CMD_remote-desktop.Dockerfile
###############################

# Configure container startup

USER root

WORKDIR /home/$NB_USER
EXPOSE 8888
COPY start-remote-desktop.sh /usr/local/bin/
COPY mc-tenant-wrapper.sh /usr/local/bin/mc
COPY trino-wrapper.sh /usr/local/bin/trino
RUN chmod +x /usr/local/bin/trino
RUN chsh -s /bin/bash $NB_USER

# Add --user to all pip install calls and point pip to Artifactory repository
COPY pip.conf /tmp/pip.conf
RUN cat /tmp/pip.conf >> /etc/pip.conf && rm /tmp/pip.conf \
    && pip config set global.timeout 300

# Point conda to Artifactory repository
COPY .condarc /tmp/.condarc
RUN cat /tmp/.condarc > /opt/conda/.condarc && rm /tmp/.condarc

# Point R to Artifactory repository
COPY Rprofile.site /tmp/Rprofile.site
RUN cat /tmp/Rprofile.site >> /usr/local/lib/R/etc/Rprofile.site && rm /tmp/Rprofile.site

USER $NB_USER
ENTRYPOINT ["tini", "--"]
CMD ["start-remote-desktop.sh"]
