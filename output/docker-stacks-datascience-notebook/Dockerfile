FROM jupyter/datascience-notebook:9ed3b8de5de1

###############################
###  docker-bits/∞_CMD.Dockerfile
###############################

# Configure container startup

USER root
WORKDIR /home/$NB_USER
EXPOSE 8888

COPY mc-tenant-wrapper.sh /usr/local/bin/mc
COPY trino-wrapper.sh /usr/local/bin/trino
RUN chmod +x /usr/local/bin/trino

# Add --user to all pip install calls and point pip to Artifactory repository
COPY pip.conf /tmp/pip.conf
RUN cat /tmp/pip.conf >> /etc/pip.conf && rm /tmp/pip.conf

# Point R to Artifactory repository
COPY Rprofile.site /tmp/Rprofile.site
RUN cat /tmp/Rprofile.site >> /opt/conda/lib/R/etc/Rprofile.site && rm /tmp/Rprofile.site

# MOVE HERE TEMPORARILY
COPY start-custom.sh /usr/local/bin/

# .conda already exists with an environments.txt
# conda info upon bootup says read only, but after conda install it goes to writable
# conda install zip
# docker run --rm -p 8888:8888 -e NB_PREFIX=/notebook/username/notebookname --name delete jlabdelete
RUN mkdir /home/$NB_USER/.conda-pack && \ 
    fix-permissions /home/$NB_USER

# Point conda to Artifactory repository
#TEMPORARILY CHANGE TO PUBLIC URL SO I CAN TEST on dev / locally
RUN conda config --add channels https://jfrog.aaw.cloud.statcan.ca/artifactory/api/conda/conda-forge-remote --system && \
    conda config --remove channels conda-forge --system 
    #&& \
    #conda config --add envs_dirs /home/$NB_USER/.conda-pack  --system && \
    #conda config --add pkgs_dirs /home/$NB_USER/.conda-pack  --system && \
    #conda config --set root_prefix /home/$NB_USER/.conda-pack --system 

#ENV CONDA_DIR /home/$NB_USER/.conda-pack

# CHECK HOW BIG THE CONDA CLONE TAKES
#RUN conda create --name downloadedpkg --clone /opt/conda
# idk check how this works
RUN touch /home/$NB_USER/test.txt

USER $NB_USER
ENTRYPOINT ["tini", "--"]
CMD ["start-custom.sh"]
