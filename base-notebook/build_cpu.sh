#!/usr/bin/env bash
IMAGE_TAG="base-notebook-cpu"
source ../build_settings.env  # Defines $UPSTREAM_CONTAINER_CPU
docker build -t $IMAGE_TAG --build-arg BASE_CONTAINER=$UPSTREAM_CONTAINER_CPU .
