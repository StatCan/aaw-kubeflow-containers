# Configure container startup

USER root

WORKDIR /home/$NB_USER
EXPOSE 8888
COPY start-remote-desktop.sh /usr/local/bin/
COPY mc-tenant-wrapper.sh /usr/local/bin/mc
RUN chsh -s /bin/bash $NB_USER

# Add --user to all pip install calls
COPY pip.conf /tmp/pip.conf
RUN cat /tmp/pip.conf >> /etc/pip.conf && rm /tmp/pip.conf

USER $NB_USER
ENTRYPOINT ["tini", "--"]
CMD ["start-remote-desktop.sh"]
