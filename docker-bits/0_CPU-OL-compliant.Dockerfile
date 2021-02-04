ARG BASE_VERSION=r-4.0.3

# temporarily hard coding docker image tag to r-4.0.3 to avoid using the current tag passed in --build-arg in CI for OL. 
# Should be replaced back to $BASE_VERSION when current images are replaced for the OL ones 
FROM jupyter/datascience-notebook:r-4.0.3

USER root
ENV PATH="/home/jovyan/.local/bin/:${PATH}"

RUN apt-get update --yes \
    && apt-get install --yes language-pack-fr \
    && rm -rf /var/lib/apt/lists/*
