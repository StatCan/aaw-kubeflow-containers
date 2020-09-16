#!/usr/bin/env bash
IMAGE_TAG="minimal-notebook-gpu"
BASE_CONTAINER="base-notebook-gpu"
docker build -t $IMAGE_TAG --build-arg BASE_CONTAINER=$BASE_CONTAINER .
