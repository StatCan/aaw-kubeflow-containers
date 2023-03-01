# Docker-stacks version tags (eg: `r-4.0.3`) are LIVE images that are frequently updated.  To avoid unexpected
# image updates, pin to the docker-stacks git commit SHA tag.
# It can be obtained by running `docker inspect repo/imagename:tag@digest` or from
# https://github.com/jupyter/docker-stacks/wiki

ARG BASE_VERSION=ed2908bbb62e

FROM k8scc01covidacr.azurecr.io/sas4c:0.0.3 as SASHome
FROM jupyter/datascience-notebook:$BASE_VERSION

USER root

ENV PATH="/home/jovyan/.local/bin/:${PATH}"

RUN apt-get update --yes \
    && apt-get install --yes language-pack-fr \
    && rm -rf /var/lib/apt/lists/*

#updates package to fix CVE-2023-0286 https://github.com/StatCan/daaas-private/issues/57
#TODO: Evaluate if this is still necessary when updating the base image
RUN pip install --force-reinstall cryptography==39.0.1 && \
   fix-permissions $CONDA_DIR && \
   fix-permissions /home/$NB_USER