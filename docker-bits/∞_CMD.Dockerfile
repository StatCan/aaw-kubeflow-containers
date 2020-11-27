# Configure container startup

WORKDIR /home/$NB_USER
EXPOSE 8888
COPY start-custom.sh /usr/local/bin/
USER $NB_USER
ENTRYPOINT ["tini", "--"]
CMD ["start-custom.sh"]
