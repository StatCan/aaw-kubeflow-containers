#!/usr/bin/env bash
BASE_CONTAINER="jupyter/datascience-notebook:04f7f60d34a6"
DOCKERFILE="./Dockerfile"
TAG="base-notebook-cpu"  # Should include SHA

bash ../scripts/build.sh -b $BASE_CONTAINER -d $DOCKERFILE -t $TAG
