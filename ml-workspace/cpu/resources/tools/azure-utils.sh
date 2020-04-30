#!/bin/sh

# Stops script execution if a command has an error
set -e

echo "Installing Azure Tooling Collection. Please wait..."
pip install --no-cache-dir \
        azure \
        msrestazure \
        azure-mgmt-resource \
        azure-mgmt-datalake-store

# Install vscode azure extension 
if hash code 2>/dev/null; then
    # https://marketplace.visualstudio.com/items?itemName=ms-vscode.vscode-node-azure-pack
    LD_LIBRARY_PATH="" LD_PRELOAD="" code --user-data-dir=$HOME/.config/Code/ --extensions-dir=$HOME/.vscode/extensions/ --install-extension ms-vscode.vscode-node-azure-pack
else
    echo "Please install the desktop version of vscode via the vs-code-desktop.sh script to install azure vscode extensions."
fi