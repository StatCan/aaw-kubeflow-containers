#!/bin/sh

# Stops script execution if a command has an error
set -e

if ! hash ruby 2>/dev/null; then
    echo "Installing Ruby Interpreter. Please wait..."
    apt-get update
    apt-get install -y ruby-full
else
    echo "Ruby Interpreter is already installed"
fi