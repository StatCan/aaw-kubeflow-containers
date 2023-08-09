# Configure container startup

USER root

WORKDIR /home/$NB_USER
EXPOSE 8888
COPY start-custom.sh /usr/local/bin/
COPY mc-tenant-wrapper.sh /usr/local/bin/mc
COPY trino-wrapper.sh /usr/local/bin/trino

# Add --user to all pip install calls and point pip to Artifactory repository
COPY pip.conf /tmp/pip.conf
RUN cat /tmp/pip.conf >> /etc/pip.conf && rm /tmp/pip.conf \
    && pip config set global.timeout 300

# Add .Rprofile to /tmp so we can install it in start-custom.sh
COPY .Rprofile /tmp/.Rprofile

USER $NB_USER
ENTRYPOINT ["tini", "--"]
CMD ["start-custom.sh"]
