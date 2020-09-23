#!/usr/bin/env bash
IMAGE_TAG="r-studio-cpu"
BASE_CONTAINER="minimal-notebook-cpu"
docker build -t $IMAGE_TAG --build-arg BASE_CONTAINER=$BASE_CONTAINER .
