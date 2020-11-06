#!/usr/bin/env bash
set -e

# This uses https://github.com/iot-salzburg/gpu-jupyter to build a GPU version 
# of the docker-stacks (https://github.com/jupyter/docker-stacks) 
# datascience-notebook Dockerfile.  Different from standard gpu-jupyter, the 
# Dockerfile from this wrapper will OMIT installing GPU-related software
# pytorch and tensorflow) as we want notebook images available without these 
# pre-installed

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

# Clone if gpu-jupyter doesn't exist, and set to the given commit or the default commit
# (adapted from gpu-jupyter)
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

# Create the Dockerfile with gpu-jupyter
cd $GPU_JUPYTER_DIR

# Edit gpu-jupyter on the fly to remove installation of GPU-related packages (pytorch/tf)
# by commenting out the addition of these packages from the Dockerfile generation script.
# For a little robustness, first test whether our search string hits anything
PATTERN="cat src\/Dockerfile\.gpulibs"
FOUND=$(grep "$PATTERN" generate-Dockerfile.sh || echo "")

if [[ -z "$FOUND" ]]; then
  echo "Could not find/remove gpulibs insertion in generate-Dockerfile.sh.  Aborting"
  exit 1
else
  REPLACE="echo \"# gpulibs omitted and to be installed later\" >> \$DOCKERFILE\n# \1"
  if [[ $(uname -s) == "Darwin" ]]; then
    # mac has different sed syntax...
    sed -E -i '' "s/^($PATTERN)/$REPLACE"/ generate-Dockerfile.sh
  else
    # Everyone else
    sed -E -i "s/^($PATTERN)/$REPLACE"/ generate-Dockerfile.sh
  fi
fi

# generate Dockerfile
./generate-Dockerfile.sh -c $DOCKER_STACKS_HEAD_COMMIT --no-useful-packages

# Copy the Dockerfile and any required build context files back to working directory
# Can't use 'cp *' directly because it will return an error code due to subdirectories in .build
find .build/ -maxdepth 1 -type f | xargs -I {} cp {} $CWD
cd $CWD