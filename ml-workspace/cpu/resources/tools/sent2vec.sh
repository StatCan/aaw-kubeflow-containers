#!/bin/sh

# Stops script execution if a command has an error
set -e

#https://github.com/epfml/sent2vec
echo "Installing Sent2vec. Please wait..."
pip install -U --no-cache-dir git+https://github.com/epfml/sent2vec
