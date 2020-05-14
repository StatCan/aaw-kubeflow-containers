#!/bin/sh

# Stops script execution if a command has an error
set -e


if hash nvidia-smi 2>/dev/null; then
    echo "Installing Rapids.ai. Please wait..."
    conda install --yes -c rapidsai -c nvidia -c conda-forge -c defaults rapids=0.11 python=3.7 cudatoolkit=10.1
else
    echo "Nvidia-smi is not installed. Rapids.ai requires CUDA support, so it cannot be installed within this container."
fi
