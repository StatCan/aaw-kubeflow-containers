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
    && rm -rf /var/lib/apt/lists/* \
    && chmod +x /usr/bin/clean-layer.sh

RUN apt-get update --yes \
    && sudo apt-get -y install gnupg \
    && apt-get -y install gnupg2

RUN curl -sS https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor |  tee /etc/apt/trusted.gpg.d/mssql.gpg
RUN curl https://packages.microsoft.com/config/ubuntu/22.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update
RUN ACCEPT_EULA=Y apt-get install -y msodbcsql18

RUN apt-get install --yes msodbcsql18

RUN apt-get update --yes \
    && apt-get install --yes unzip \
    && apt-get install alien --yes \
    && apt-get install libaio1

RUN mkdir /opt/oracle
RUN chmod +x /opt/oracle
RUN curl -s -O https://download.oracle.com/otn_software/linux/instantclient/2350000/instantclient-basic-linux.x64-23.5.0.24.07.zip

RUN unzip instantclient-basic-linux.x64-23.5.0.24.07.zip -d /opt/oracle


# RUN sh -c 'echo /usr/lib/oracle/23/client64/lib/ > /etc/ld.so.conf.d/oracle.conf'
# RUN ldconfig
# RUN ln -s i/opt/oracle$ cd instantclient_23_5 instantclient

ENV LD_LIBRARY_PATH=/opt/oracle/instantclient_23_5:$LD_LIBRARY_PATH 
ENV PATH=/opt/oracle/instantclient_23_5:$PATH
ENV ORACLE_HOME=/opt/oracle/instantclient_23_5 

RUN sh -c 'echo /opt/oracle/instantclient_23_5/lib/ > /etc/ld.so.conf.d/oracle.conf'
RUN sh -c 'echo /opt/oracle/instantclient_23_5/ > /etc/ld.so.conf.d/oracle-instantclient.conf'

RUN ln -s /opt/oracle/instantclient_23_5/libclntsh.so.23.1 /usr/lib/libclntsh.so
# Ended up downloading the zip packages and installing in 
# /opt/oracle/instantclient_23_4, 
# and then then I added env ORACLE_HOME=/opt/oracle/instantclient_23_4, 
# add same path to PATH, and made the files oracle.conf + oracle-instantclient.conf in /etc/ld.so.conf.d/, 
# with /opt/oracle/instantclient_23_4/lib/ in the first one and /opt/oracle/instantclient_23_4/ in the second (followed by sudo ldconfig)

#updates package to fix CVE-2023-0286 https://github.com/StatCan/aaw-private/issues/57
#TODO: Evaluate if this is still necessary when updating the base image
RUN pip install --force-reinstall cryptography==39.0.1 && \
   fix-permissions $CONDA_DIR && \
   fix-permissions /home/$NB_USER