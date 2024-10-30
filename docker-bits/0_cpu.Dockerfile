# Docker-stacks version tags (eg: `r-4.0.3`) are LIVE images that are frequently updated.  To avoid unexpected
# image updates, pin to the docker-stacks git commit SHA tag.
# It can be obtained by running `docker inspect repo/imagename:tag@digest` or from
# https://github.com/jupyter/docker-stacks/wiki

ARG BASE_VERSION=2024-06-17

FROM k8scc01covidacr.azurecr.io/sas4c:0.0.3 as SASHome
FROM quay.io/jupyter/datascience-notebook:$BASE_VERSION

USER root

ENV PATH="/home/jovyan/.local/bin/:${PATH}"

COPY clean-layer.sh /usr/bin/clean-layer.sh

RUN apt-get update --yes \
    && apt-get install --yes language-pack-fr \
    && apt-get upgrade --yes libwebp7 \
    && rm -rf /var/lib/apt/lists/* \
    && chmod +x /usr/bin/clean-layer.sh 

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

ENV ORACLE_HOME="/opt/oracle/instantclient_23_5:${ORACLE_HOME}"
RUN export PATH="$PATH:/opt/oracle/instantclient_23_5"
RUN export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/opt/oracle/instantclient_23_5"

RUN sh -c 'echo /opt/oracle/instantclient_23_5/lib/ > /etc/ld.so.conf.d/oracle.conf'
RUN sh -c 'echo /opt/oracle/instantclient_23_5/ > /etc/ld.so.conf.d/oracle-instantclient.conf'


RUN sh -c 'echo [OracleODBC-23ai] > /etc/odbcinst.ini'
RUN sh -c 'echo Description = Oracle ODBC Driver > /etc/odbcinst.ini'
RUN sh -c 'echo Driver = /opt/oracle/instantclient_23_5/libsqora.so.23.5 > /etc/odbcinst.ini'

RUN ln -s /opt/oracle/instantclient_23_5/libclntsh.so.23.1 /usr/lib/libclntsh.so
RUN ldconfig
