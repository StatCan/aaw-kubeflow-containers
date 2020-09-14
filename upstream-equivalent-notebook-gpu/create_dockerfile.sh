#!/usr/bin/env bash
set -e

# This uses https://github.com/iot-salzburg/gpu-jupyter to build a GPU version 
# of the docker-stacks (https://github.com/jupyter/docker-stacks) 
# datascience-notebook Dockerfilem with an extra modification where we overwrite
# the nvidia base image with one of our choice.  

# I think our current gpu comes from.  No, it feels maybe based there but then manually edited
# DOCKER_STACKS_HEAD_COMMIT="a0baf97d2506e11c6eb32fdc274a8e3edb3a4527"

# Defaults from env settings, if they exist in a default location
. ../build_settings.env || true
DOCKER_STACKS_HEAD_COMMIT="$UPSTREAM_CONTAINER_CPU_HEAD_COMMIT"
GPU_JUPYTER_HEAD_COMMIT="$GPU_JUPYTER_HEAD_COMMIT" 

GPU_JUPYTER_DIR=".gpu-jupyter"
CWD=$(pwd)

USAGE_MESSAGE="
Usage: $0 [--docker_stacks_head_commit COMMIT_SHA] [--gpu_jupyter_head_commit COMMIT_SHA]
Where:
    --docker_stacks_head_commit: Commit SHA from docker-stacks to base this Dockerfile on (default=$DOCKER_STACKS_HEAD_COMMIT)
    --gpu_jupyter_head_commit: Commit SHA from gpu-jupyter to use for the GPU Dockerfile building scripts (default=$GPU_JUPYTER_HEAD_COMMIT)
"

while [[ "$#" -gt 0 ]]; do case $1 in
  --docker_stacks_head_commit) DOCKER_STACKS_HEAD_COMMIT="$2"; shift;;
  --gpu_jupyter_head_commit) GPU_JUPYTER_HEAD_COMMIT="$2"; shift;;
  *) echo "Unknown parameter passed: $1" &&
    echo "$USAGE_MESSAGE"; exit 1;;
esac; shift; done

# Basic input validation
# Try pulling latest from acr to get a source for cache-from
if [ -z "$DOCKER_STACKS_HEAD_COMMIT" ]; then
    echo "$USAGE_MESSAGE"; exit 1;
fi

# (adapted from gpu-jupyter)
# Clone if gpu-jupyter doesn't exist, and set to the given commit or the default commit
ls $GPU_JUPYTER_DIR/generate-Dockerfile.sh  > /dev/null 2>&1  || (echo "gpu-jupyter was not found, cloning repository" \
 && git clone https://github.com/iot-salzburg/gpu-jupyter.git $GPU_JUPYTER_DIR)
echo "Set gpu-jupyter to commit '$GPU_JUPYTER_HEAD_COMMIT'."
if [[ "$GPU_JUPYTER_HEAD_COMMIT" == "latest" ]]; then
  echo "WARNING, the latest commit of gpu-jupyter is used. This may result in version conflicts"
  cd $GPU_JUPYTER_DIR && git pull && cd -
else
  export GOT_HEAD="false"
  cd $GPU_JUPYTER_DIR && git pull && git reset --hard "$GPU_JUPYTER_HEAD_COMMIT" > /dev/null 2>&1  && cd - && export GOT_HEAD="true"
  echo "$GPU_JUPYTER_HEAD_COMMIT"
  if [[ "$GOT_HEAD" == "false" ]]; then
    echo "Error: The given sha-commit is invalid."
    echo "Usage: $0 -c [sha-commit] # set the head commit of the gpu-jupyter submodule (https://github.com/iot-salzburg/gpu-jupyter)."
    echo "Exiting"
    exit 2
  else
    echo "Set head to given commit."
  fi
fi

cd $GPU_JUPYTER_DIR
./generate-Dockerfile.sh -c $DOCKER_STACKS_HEAD_COMMIT
# Copy the Dockerfile and any required build context files back to working directory
cp .build/* $CWD
cd $CWD
