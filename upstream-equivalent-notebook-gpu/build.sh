#!/usr/bin/env bash
create_dockerfile.sh

IMAGE_TAG="upstream-equivalent-notebook-gpu"
docker build -t $IMAGE_TAG .