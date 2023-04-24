# Docker-stacks version tags (eg: `r-4.0.3`) are LIVE images that are frequently updated.  To avoid unexpected
# image updates, pin to the docker-stacks git commit SHA tag.
# It can be obtained by running `docker inspect repo/imagename:tag@digest` or from
# https://github.com/jupyter/docker-stacks/wiki

ARG BASE_VERSION=v1.5.0
FROM public.ecr.aws/j1r0q0g6/notebooks/notebook-servers/codeserver-python:$BASE_VERSION

USER root

ENV PATH="/home/jovyan/.local/bin/:${PATH}"

RUN apt-get update --yes \
    && apt-get install --yes language-pack-fr \
    && rm -rf /var/lib/apt/lists/*