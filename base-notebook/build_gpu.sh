#!/usr/bin/env bash
IMAGE_TAG="base-notebook-cpu"
BASE_CONTAINER="upstream-equivalent-notebook-gpu"
docker build -t $IMAGE_TAG --build-arg BASE_CONTAINER=$BASE_CONTAINER .
