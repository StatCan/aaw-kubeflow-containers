#!/usr/bin/env bash
BASE_CONTAINER="minimal-notebook-cpu"
DOCKERFILE="./Dockerfile"
TAG="geomatics-notebook-cpu"  # Should include SHA

docker build -f $DOCKERFILE -t $TAG --build-arg BASE_CONTAINER=$BASE_CONTAINER .
