USER root

# ODBC drivers
# Add the signature to trust the Microsoft repo
RUN curl https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc && \
    # Add repo to apt sources
    curl https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list

RUN apt-get update && \
    # Install the driver
    ACCEPT_EULA=Y apt-get install -y msodbcsql18 && \
    # optional: for bcp and sqlcmd
    ACCEPT_EULA=Y apt-get install -y mssql-tools18 && \
    # installing unixODBC
    apt-get install -y unixodbc unixodbc-dev && \
    # libaio1 needed for Oracle Instant Client
    apt-get install -y libaio1 && \
    pip install --no-cache-dir --quiet pyodbc && \
    rm -rf /var/lib/apt/lists/* && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

RUN echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bashrc && \
    source ~/.bashrc

# installing Oracle Instant Client
RUN curl -O https://download.oracle.com/otn_software/linux/instantclient/2350000/instantclient-basic-linux.x64-23.5.0.24.07.zip && \
    unzip instantclient-basic-linux.x64-23.5.0.24.07.zip -d /opt/oracle/ && \
    echo /opt/oracle/instantclient_23_5 > /etc/ld.so.conf.d/oracle-instantclient.conf && \
    ldconfig

ENV PATH /opt/oracle/instantclient_23_5:${PATH}

# installing Oracle ODBC driver
RUN curl -O https://download.oracle.com/otn_software/linux/instantclient/2350000/instantclient-odbc-linux.x64-23.5.0.24.07.zip && \
    unzip -oj instantclient-odbc-linux.x64-23.5.0.24.07.zip -d /opt/oracle/instantclient_23_5 && \
    /opt/oracle/instantclient_23_5/odbc_update_ini.sh / /opt/oracle/instantclient_23_5

# add relevent files needed for oracle
COPY dbConnection/LINUX_CLIENT_WALLET /opt/oracle/instantclient_23_5/LINUX_CLIENT_WALLET
COPY dbConnection/*.ora /opt/oracle/instantclient_23_5/network/admin/
#give users permissions to edit the alias file
RUN chmod a+w /opt/oracle/instantclient_23_5/network/admin
RUN chown $NB_UID:$NB_GID /opt/oracle/instantclient_23_5/network/admin/tnsnames.ora
