FROM jupyter/datascience-notebook:512afd49b925

###############################
###  docker-bits/∞_CMD.Dockerfile
###############################

# Configure container startup

USER root
WORKDIR /home/$NB_USER
EXPOSE 8888
COPY start-custom.sh /usr/local/bin/
COPY mc-tenant-wrapper.sh /usr/local/bin/mc 

# Add --user to all pip install calls and point pip to Artifactory repository
COPY pip.conf /tmp/pip.conf
RUN cat /tmp/pip.conf >> /etc/pip.conf && rm /tmp/pip.conf

# Point R to Artifactory repository
COPY Rprofile.site /tmp/Rprofile.site
RUN cat /tmp/Rprofile.site >> /opt/conda/lib/R/etc/Rprofile.site && rm /tmp/Rprofile.site

# Point conda to Artifactory repository
RUN conda config --add channels http://jfrog-platform-artifactory-ha.jfrog-system:8081/artifactory/api/conda/conda-forge-remote --system && \
    conda config --remove channels conda-forge --system

# TEST USING A .netrc file
# Try using anonymous@.... 
# I dont want things printed in output when trying to install
# can change the value in .netrc to be a secret later
# I have tested this with my own artifactory and it seems to work fine 
#COPY .netrc ~/.netrc
#RUN chown $NB_USER ~/.netrc
#RUN chmod 0600 ~/.netrc


USER $NB_USER
ENTRYPOINT ["tini", "--"]
CMD ["start-custom.sh"]
