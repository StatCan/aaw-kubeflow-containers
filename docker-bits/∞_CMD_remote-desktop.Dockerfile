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

# Removal area
# Prevent screen from locking
RUN apt-get remove -y -q light-locker xfce4-screensaver \
    && apt-get autoremove -y

USER $NB_USER
ENTRYPOINT ["tini", "--"]
CMD ["start-remote-desktop.sh"]
