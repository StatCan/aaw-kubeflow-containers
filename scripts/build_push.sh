#!/usr/bin/env bash

set -e

USAGE_MESSAGE="
This script handles building, tagging, and (optionally) pushing an image to a docker repo.  It builds the image requested, adds two tags (one intended for version pinning such as a git sha, and one intended for something like 'latest').  It optionally can: 

* pull an existing image to use as a layer cache
* pass a build-arg 'BASE_CONTAINER' to the 'docker build' command, indicating the container to build from
* prune either all docker images/containers or the images built since starting this script (typically just the images built here, but not guaranteed if other processes run in parallel)

Usage: $0 --registry REGISTRY --image_name IMAGE_NAME --tag_pinned GITHUB_SHA --tag_latest TAG_LATEST [--base_container BASE_CONTAINER] [--cache-from FULL_IMAGE_PATH] [--push] [--prune]
Where:
    registry: container registry full path, such as myRegistry.azurecr.io
    image_name: name of the image to be pushed
    tag_pinned: tag used for the 'pinned' version (typically a github sha)
    tag_latest: tag used for the latest version, both to pull a recent cache and push back to registry
    base_container: (optional) if set, pass this value to docker as a build arg (eg: '--build-arg BASE_CONTAINER=THIS_VALUE')
    cache_from: (optional) if set, will pull this image to help caching.  Typically set to a recently built version of this image, such as myRegistry.azurecr.io/IMAGE_NAME:TAG_LATEST
    push: (optional) if set, will push all products to registry.  Default is unset
    prune_all: (optional) if set, will 'docker system prune -f -a' after build.  Default is unset
    prune_this: (optional) if set, will remove all images built since this job started (like prune_all but only for products of this job)
"

PUSH=""
PRUNE_ALL=""
PRUNE_THIS=""
CACHE_FROM=""
BASE_CONTAINER=""


# Very basic input validation
if [[ "$#" -lt 8 ]]; then
    echo "$USAGE_MESSAGE"; exit 1;
fi


# Parse input arguments
while [[ "$#" -gt 0 ]]; do case $1 in
  --registry) REGISTRY="$2"; shift;;
  --image_name) IMAGE_NAME="$2"; shift;;
  --tag_pinned) GITHUB_SHA="$2"; shift;;
  --tag_latest) LATEST="$2"; shift;;
  --base_container) BASE_CONTAINER="$2"; shift;;
  --cache_from) CACHE_FROM="$2"; shift ;;
  --push) PUSH="true"; ;;
  --prune_all) PRUNE_ALL="true"; ;;
  --prune_this) PRUNE_THIS="true"; ;;
  *) echo "Unknown parameter passed: $1" &&
    echo "$USAGE_MESSAGE"; exit 1;;
esac; shift; done


# Interpret input arguments

UNTAGGED_IMAGE="$REGISTRY/$IMAGE_NAME"
TAG_PINNED="$UNTAGGED_IMAGE:$GITHUB_SHA"
TAG_LATEST="$UNTAGGED_IMAGE:$LATEST"
echo "::set-output name=tag_pinned::$TAG_PINNED"

# If pruning only this product, remember the last image built before now so we can select 
# all since then later.
# If there are no previous images, fallback to a prune_all
if [ ! -z "$PRUNE_THIS" ]; then
  echo "Remembering the last non-intermediate image before building so we can prune recent images later"
  PREVIOUS_IMAGE=$(docker images -q | head -n 1)
  if [ -z "$PREVIOUS_IMAGE" ]; then
    echo "No previous images built.  Will do a prune all after completion"
    PRUNE_ALL="true"
    PRUNE_THIS=""
  fi
fi

BUILD_COMMAND="docker build"

# Initialize layer caching by pulling the cache_from image
if [ -z "$CACHE_FROM" ]; then
    echo "Skipping cache pull"
else
    echo "Pulling cache image"
    docker pull "$CACHE_FROM" || true
    BUILD_COMMAND="$BUILD_COMMAND --cache-from $CACHE_FROM"
fi

echo "Building image"
if [ -z "$BASE_CONTAINER" ]; then
    docker build --cache-from $CACHE_FROM -t $TAG_PINNED .
else
    docker build --cache-from $CACHE_FROM -t $TAG_PINNED --build-arg BASE_CONTAINER=$BASE_CONTAINER .
fi
echo "building docker with:"
echo $BUILD_COMMAND
`$BUILD_COMMAND`
docker tag "$TAG_PINNED" "$TAG_LATEST"

if [ -z "$PUSH" ]; then
    echo "Skipping pushing images"
else
    echo "Pushing images"
    docker push "$TAG_PINNED"
    docker push "$TAG_LATEST"
fi

if [ ! -z "$PRUNE_ALL" ]; then
    echo "Pruning all docker images"
    docker rmi -f $(docker images -a -q)
fi

if [ ! -z "$PRUNE_THIS" ]; then
    # This technically prunes images build DURING this session.  If another process
    # builds a docker image while this was running, it will be removed too
    echo "Pruning docker images built since $PREVIOUS_IMAGE"
    docker rmi -f $(docker images -a -q --filter=since=$PREVIOUS_IMAGE)
fi
