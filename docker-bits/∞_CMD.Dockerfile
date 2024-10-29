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

# Adding oracle here instead of inside each cp files
#

RUN apt-get update --yes \
    && sudo apt-get -y install gnupg

RUN curl -sS https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor |  tee /etc/apt/trusted.gpg.d/mssql.gpg
RUN curl https://packages.microsoft.com/config/ubuntu/22.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
# RUN apt-get update
RUN ACCEPT_EULA=Y apt-get install -y msodbcsql18

# RUN apt-get install --yes msodbcsql18

RUN apt-get update --yes \
    && apt-get install --yes unzip \
    && apt-get install alien --yes \
    && apt-get install libaio1

RUN mkdir /opt/oracle
RUN chmod +x /opt/oracle

RUN curl -s -O https://download.oracle.com/otn_software/linux/instantclient/2350000/instantclient-basic-linux.x64-23.5.0.24.07.zip
RUN unzip instantclient-basic-linux.x64-23.5.0.24.07.zip -d /opt/oracle

RUN curl -s -O https://download.oracle.com/otn_software/linux/instantclient/2350000/oracle-instantclient-basic-23.5.0.24.07-1.el9.x86_64.rpm
RUN alien -i oracle-instantclient-basic-23.5.0.24.07-1.el9.x86_64.rpm
RUN sh -c 'echo /usr/lib/oracle/23/client64/lib/ > /etc/ld.so.conf.d/oracle.conf'
RUN ldconfig
# RUN ln -s i/opt/oracle$ cd instantclient_23_5 instantclient

RUN export PATH="$PATH:/opt/oracle/instantclient_23_5"
RUN export ORACLE_HOME="$PATH:/opt/oracle/instantclient_23_5"
RUN export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/opt/oracle/instantclient_23_5"

RUN sh -c 'echo /opt/oracle/instantclient_23_5/lib/ > /etc/ld.so.conf.d/oracle.conf'
RUN sh -c 'echo /opt/oracle/instantclient_23_5/ > /etc/ld.so.conf.d/oracle-instantclient.conf'


RUN sh -c 'echo [OracleODBC-23ai] > /etc/odbcinst.ini'
RUN sh -c 'echo Description = Oracle ODBC Driver > /etc/odbcinst.ini'
RUN sh -c 'echo Driver = /opt/oracle/instantclient_23_5/libsqora.so.23.5 > /etc/odbcinst.ini'

RUN ln -s /opt/oracle/instantclient_23_5/libclntsh.so.23.1 /usr/lib/libclntsh.so
RUN ldconfig

USER $NB_USER
ENTRYPOINT ["tini", "--"]
CMD ["start-custom.sh"]
