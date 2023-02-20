#!/bin/bash

# Use an argument if available.
if test -n "$1"; then
    VERSION=$1
fi

if ! echo "$VERSION" | grep -q '^[0-9.]*$'; then
    echo "$VERSION seems invalid. Should be numeric. E.g. 11.0 " >&2
    exit 1
fi

REPO=https://gitlab.com/nvidia/container-images/cuda/-/raw/master/dist
CUDNN=cudnn8
OS=ubuntu1804

cat <<EOF | grep -v '^\(FROM\|ARG IMAGE_NAME\|LABEL maintainer\)' # > 1_CUDA-$VERSION.Dockerfile
# Cuda stuff for v$VERSION

## $REPO/$VERSION/$OS/base/Dockerfile

###########################
### Base
###########################
# $REPO/$VERSION/$OS/base/Dockerfile

$(curl -s $REPO/$VERSION/$OS/base/Dockerfile)

# ###########################
# ### Devel
# ###########################
# # $REPO/$VERSION/$OS/devel/Dockerfile
#
# \$(curl -s $REPO/$VERSION/$OS/devel/Dockerfile)

###########################
### Runtime
###########################
# $REPO/$VERSION/$OS/runtime/Dockerfile

$(curl -s $REPO/$VERSION/$OS/runtime/Dockerfile)

###########################
### CudNN
###########################
# $REPO/$VERSION/$OS/runtime/$CUDNN/Dockerfile

$(curl -s $REPO/$VERSION/$OS/runtime/$CUDNN/Dockerfile)

EOF
