#!/bin/sh

# Stops script execution if a command has an error
set -e

if [ ! -f "/usr/local/bin/code-server"  ]; then
    echo "Installing VS Code Server. Please wait..."
    cd ${RESOURCES_PATH}
    # CODE_SERVER_VERSION=2.1698
    # VS_CODE_VERSION=$CODE_SERVER_VERSION-vsc1.41.1
    # wget -q https://github.com/cdr/code-server/releases/download/$CODE_SERVER_VERSION/code-server$VS_CODE_VERSION-linux-x86_64.tar.gz -O ./vscode-web.tar.gz
    # Use older version, since newer has some problems with python extension
    VS_CODE_VERSION=2.1692-vsc1.39.2
    wget -q https://github.com/cdr/code-server/releases/download/$VS_CODE_VERSION/code-server$VS_CODE_VERSION-linux-x86_64.tar.gz -O ./vscode-web.tar.gz
    tar xfz ./vscode-web.tar.gz
    mv ./code-server$VS_CODE_VERSION-linux-x86_64/code-server /usr/local/bin
    chmod -R a+rwx /usr/local/bin/code-server
    rm ./vscode-web.tar.gz
    rm -rf ./code-server$VS_CODE_VERSION-linux-x86_64
else
    echo "VS Code Server is already installed"
fi
