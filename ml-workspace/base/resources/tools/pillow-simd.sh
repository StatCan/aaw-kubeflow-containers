#!/bin/sh

# Stops script execution if a command has an error
set -e

# No install argument needed

echo "Installing Pillow SIMD. Please wait..."

# Install libjpeg-turbo and Pillow-SIMD for faster Image Processing
# https://docs.fast.ai/performance.html#faster-image-processing
# Use better pillow simd install: https://github.com/uploadcare/pillow-simd/issues/44

conda clean -i

conda uninstall -y --force pillow pil jpeg libtiff libjpeg-turbo
pip uninstall -y pillow pil jpeg libtiff libjpeg-turbo
conda install -y --no-deps -c conda-forge libjpeg-turbo
CFLAGS="${CFLAGS} -mavx2" pip install --upgrade --no-cache-dir --force-reinstall --no-binary :all: --compile pillow-simd==7.0.0.post2
conda install -y --no-deps jpeg libtiff

conda clean --all -f -y
export USER_GID=1000
fix-permissions.sh $CONDA_DIR
fix-permissions.sh /home/jovyan

echo "This should return a version with post prefix if pillow-simd is used:"
python -c "from PIL import Image; print(Image.__version__)"
echo "This should return True of libjpeg-turbo is enabled:"
python -c "from PIL import features; print(features.check_feature('libjpeg_turbo'))"
sleep 15