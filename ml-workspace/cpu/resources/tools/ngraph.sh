#!/bin/sh

# Stops script execution if a command has an error
set -e

# https://www.ngraph.ai/
echo "Installing NGraph and PlaidML. Please wait..."
pip install -U --no-cache-dir ngraph-core ngraph-onnx plaidml
# ngraph-tensorflow-bridge NGRAPH_TF_BACKEND="INTELGPU"