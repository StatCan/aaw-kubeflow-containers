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
    && apt-get install --yes unzip
RUN mkdir /opt/oracle
RUN chmod +x /opt/oracle
RUN curl -s -O https://download.oracle.com/otn_software/linux/instantclient/2350000/instantclient-basic-linux.x64-23.5.0.24.07.zip
RUN curl -s -O https://download.oracle.com/otn_software/linux/instantclient/2350000/instantclient-odbc-linux.x64-23.5.0.24.07.zip
RUN ls

RUN unzip instantclient-basic-linux.x64-23.5.0.24.07.zip -d /opt/oracle
RUN unzip instantclient-odbc-linux.x64-23.5.0.24.07.zip -d /opt/oracle



#updates package to fix CVE-2023-0286 https://github.com/StatCan/aaw-private/issues/57
#TODO: Evaluate if this is still necessary when updating the base image
RUN pip install --force-reinstall cryptography==39.0.1 && \
   fix-permissions $CONDA_DIR && \
   fix-permissions /home/$NB_USER