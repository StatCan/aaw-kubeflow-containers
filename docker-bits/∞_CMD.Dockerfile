# Configure container startup

USER root
WORKDIR /home/$NB_USER
EXPOSE 8888
COPY start-custom.sh /usr/local/bin/
COPY mc-tenant-wrapper.sh /usr/local/bin/mc
COPY trino-wrapper.sh /usr/local/bin/trino
RUN chmod +x /usr/local/bin/trino

# Add --user to all pip install calls and point pip to Artifactory repository
COPY pip.conf /tmp/pip.conf
RUN cat /tmp/pip.conf >> /etc/pip.conf && rm /tmp/pip.conf

# Point R to Artifactory repository
COPY Rprofile.site /tmp/Rprofile.site
RUN cat /tmp/Rprofile.site >> /opt/conda/lib/R/etc/Rprofile.site && rm /tmp/Rprofile.site

# Point conda to Artifactory repository
#TEMPORARILY CHANGE TO PUBLIC URL SO I CAN TEST on dev / locally
RUN conda config --add channels https://jfrog.aaw.cloud.statcan.ca/artifactory/api/conda/conda-forge-remote --system && \
    conda config --remove channels conda-forge --system && \
    conda config --add envs_dirs /home/$NB_USER/conda-persistent --system && \
    conda config --add pkgs_dirs /home/$NB_USER/conda-persistent --system

USER $NB_USER
ENTRYPOINT ["tini", "--"]
CMD ["start-custom.sh"]
