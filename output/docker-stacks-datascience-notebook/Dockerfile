FROM jupyter/datascience-notebook:r-4.0.3

###############################
###  docker-bits/∞_CMD.Dockerfile
###############################

# Configure container startup

WORKDIR /home/$NB_USER
EXPOSE 8888
COPY start-custom.sh /usr/local/bin/
COPY mc-tenant-wrapper.sh /usr/local/bin/mc 
USER $NB_USER
ENTRYPOINT ["tini", "--"]
CMD ["start-custom.sh"]
