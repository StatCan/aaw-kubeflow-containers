#!/usr/bin/env bash
BASE_CONTAINER="base-notebook-cpu"
DOCKERFILE="./Dockerfile"
TAG="minimal-notebook-cpu"  # Should include SHA

bash ../scripts/build.sh -b $BASE_CONTAINER -d $DOCKERFILE -t $TAG
