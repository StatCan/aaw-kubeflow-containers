# Tag images with standard tags
# Inputs: 
# 	SOURCE_FULL_IMAGE_NAME ('repo/name:tag' image we will add tags to) 
#							<-- use if you're 'building' by retagging an existing image with different name
#	IMAGE_NAME (name to use for new tags)
# 	REPO (repo to use for new tags)
# 	GIT_SHA (full SHA for commit)
# 	BRANCH_NAME (if set, will override BRANCH_NAME computed below)
# 	IMAGE_VERSION (version of image, increments on breaking change)
# 	IS_LATEST (occurs on merges into main, will push and clobber previous image tags)

# End repo with exactly one trailing slash, unless it is empty
REPO=$(echo "${REPO}" | sed 's:/*$:/:' | sed 's:^\s*/*\s*$::') ;\

REPO_IMAGE_NAME="${REPO}${IMAGE_NAME}"

# Infer source image's full name, if not specified.  
# Default to normal REPO/IMAGE:TAG
SOURCE_FULL_IMAGE_NAME=${SOURCE_FULL_IMAGE_NAME:-${REPO_IMAGE_NAME}:${TAG}}
echo "Adding tags to $SOURCE_FULL_IMAGE_NAME"

echo "Tagging with GIT_SHA ($GIT_SHA)"
docker tag $SOURCE_FULL_IMAGE_NAME $REPO_IMAGE_NAME:$GIT_SHA

SHORT_SHA=$(echo "${GIT_SHA}" | cut -c1-8)  # first 8 characters of SHA
echo "Tagging with SHORT_SHA ($SHORT_SHA)"
docker tag $SOURCE_FULL_IMAGE_NAME $REPO_IMAGE_NAME:$SHORT_SHA

BRANCH_NAME=${BRANCH_NAME:-git rev-parse --abbrev-ref HEAD}
echo "Tagging with BRANCH_NAME ($BRANCH_NAME)"
docker tag $SOURCE_FULL_IMAGE_NAME $REPO_IMAGE_NAME:$BRANCH_NAME

if [ ! -z $IMAGE_VERSION ]; then
    echo "Tagging with IMAGE_VERSION ($IMAGE_VERSION)"
    docker tag $SOURCE_FULL_IMAGE_NAME $REPO_IMAGE_NAME:$IMAGE_VERSION
fi

if [ $IS_LATEST = true ]; then
    echo "Tagging with LATEST"
    docker tag $SOURCE_FULL_IMAGE_NAME $REPO_IMAGE_NAME:latest
fi
