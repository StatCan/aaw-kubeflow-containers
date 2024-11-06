FROM jupyter/datascience-notebook:ed2908bbb62e

###############################
###  docker-bits/∞_CMD.Dockerfile
###############################

# Configure container startup

USER root
WORKDIR /home/$NB_USER
EXPOSE 8888
COPY start-custom.sh start-oms.sh restart-oms.sh /usr/local/bin/
COPY trino-wrapper.sh /usr/local/bin/trino

RUN chmod +x /usr/local/bin/start-oms.sh && \
    chmod +x /usr/local/bin/restart-oms.sh

# Add --user to all pip install calls and point pip to Artifactory repository
COPY pip.conf /tmp/pip.conf
RUN cat /tmp/pip.conf >> /etc/pip.conf && rm /tmp/pip.conf

# Point R to Artifactory repository
#COPY Rprofile.site /tmp/Rprofile.site
#RUN cat /tmp/Rprofile.site >> /opt/conda/lib/R/etc/Rprofile.site && rm /tmp/Rprofile.site

# Add .Rprofile to /tmp so we can install it in start-custom.sh
COPY .Rprofile /tmp/.Rprofile

# Copy over Instructions to Home directory
ADD connect-to-filer.md /home/$NB_USER/connect-to-filer.md

# Point conda to Artifactory repository
RUN conda config --remove channels conda-forge --system

# Jose test
RUN code-server --install-extension ms-python.debugpy@2024.8.0 && \
    fix-permissions $CS_TEMP_HOME

ENV EXTENSIONS_GALLERY='{"serviceUrl":"https://code-marketplace.das-prod-cc-00.cloudnative.cloud.statcan.ca/api","itemUrl":"https://code-marketplace.das-prod-cc-00.cloudnative.cloud.statcan.ca/item","resourceUrlTemplate":"https://code-marketplace.das-prod-cc-00.cloudnative.cloud.statcan.ca/files/{publisher}/{name}/{version}/{path}"}'
USER $NB_USER
ENTRYPOINT ["tini", "--"]
CMD ["start-custom.sh"]
