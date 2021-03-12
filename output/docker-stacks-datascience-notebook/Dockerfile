FROM jupyter/datascience-notebook:r-4.0.3

###############################
###  docker-bits/∞_CMD.Dockerfile
###############################

# Configure container startup

WORKDIR /home/$NB_USER
EXPOSE 8888
COPY start-custom.sh /usr/local/bin/
COPY mc-tenant-wrapper.sh /usr/local/bin/mc 

# Add --user to all pip install calls
COPY pip.conf /tmp/pip.conf
RUN cat /tmp/pip.conf >> /etc/pip.conf && rm /tmp/pip.conf

USER $NB_USER
ENTRYPOINT ["tini", "--"]
CMD ["start-custom.sh"]
