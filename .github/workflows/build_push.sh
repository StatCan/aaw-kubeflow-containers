#!/usr/bin/env bash
set -e

USAGE_MESSAGE="
Usage: $0 --registry REGISTRY --image_name IMAGE_NAME --tag_pinned GITHUB_SHA --tag_latest TAG_LATEST --base_container BASE_CONTAINER [--cache-from FULL_IMAGE_PATH] [--push] [--prune]
Where:
    registry: container registry full path, such as myRegistry.azurecr.io
    image_name: name of the image to be pushed
    tag_pinned: tag used for the 'pinned' version (typically a github sha)
    tag_latest: tag used for the latest version, both to pull a recent cache and push back to registry
    base_container: base container used in building this image (passed to docker as a build arg)
    cache_from: (optional) if set, will pull this image to help caching.  Typically set to a recently built version of this image, such as myRegistry.azurecr.io/IMAGE_NAME:TAG_LATEST
    push: (optional) if set, will push all products to registry.  Default is unset
    prune: (optional) if set, will 'docker system prune -f -a' after build.  Default is unset
"

PUSH=""
PRUNE=""
CACHE_FROM=""


# Very basic input validation
if [[ "$#" -lt 10 ]]; then
    echo "$USAGE_MESSAGE"; exit 1;
fi

while [[ "$#" -gt 0 ]]; do case $1 in
  --registry) REGISTRY="$2"; shift;;
  --image_name) IMAGE_NAME="$2"; shift;;
  --tag_pinned) GITHUB_SHA="$2"; shift;;
  --tag_latest) LATEST="$2"; shift;;
  --base_container) BASE_CONTAINER="$2"; shift;;
  --cache_from) CACHE_FROM="$2"; shift ;;
  --push) PUSH="true"; ;;
  --prune) PRUNE="true"; ;;
  *) echo "Unknown parameter passed: $1" &&
    echo "$USAGE_MESSAGE"; exit 1;;
esac; shift; done


UNTAGGED_IMAGE="$REGISTRY/$IMAGE_NAME"
TAG_PINNED="$UNTAGGED_IMAGE:$GITHUB_SHA"
TAG_LATEST="$UNTAGGED_IMAGE:$LATEST"
echo "::set-output name=tag_pinned::$TAG_PINNED"

# Try pulling latest from acr to get a source for cache-from
if [ -z "$CACHE_FROM" ]; then
    echo "Skipping cache pull"
else
    echo "Pulling cache image"
    docker pull "$CACHE_FROM" || true
fi

docker build --cache-from $TAG_LATEST -t $TAG_PINNED --build-arg BASE_CONTAINER=$BASE_CONTAINER .
docker tag "$TAG_PINNED" "$TAG_LATEST"

if [ -z "$PUSH" ]; then
    echo "Skipping pushing images"
else
    echo "Pushing images"
    docker push "$TAG_PINNED"
    docker push "$TAG_LATEST"
fi

if [ -z "$PRUNE" ]; then
    echo "Skipping pruning docker"
else
    echo "Pruning docker"
    docker system prune -f -a
fi



