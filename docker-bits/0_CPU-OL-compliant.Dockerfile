ARG BASE_VERSION=r-4.0.3
FROM jupyter/datascience-notebook:r-4.0.3

USER root
ENV PATH="/home/jovyan/.local/bin/:${PATH}"

RUN apt-get update --yes \
    && apt-get install --yes language-pack-fr \
    && rm -rf /var/lib/apt/lists/*
