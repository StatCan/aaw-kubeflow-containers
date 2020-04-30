#!/bin/sh

# Stops script execution if a command has an error
set -e

echo "Installing Data Utils Collection. Please wait..."

apt-get update
apt-get install -y --no-install-recommends \
        redis-server \
        postgresql \
        mysql-client \
        mysql-server \
        s3cmd \
        libsqlite3-dev \
        libhdf5-serial-dev

# Install jupyterlab sql: https://github.com/pbugnion/jupyterlab-sql
pip install jupyterlab_sql
jupyter serverextension enable jupyterlab_sql --py --sys-prefix
jupyter lab build
jupyter lab clean
jlpm cache clean

# Install vscode extensions
if hash code 2>/dev/null; then
    # https://marketplace.visualstudio.com/items?itemName=RandomFractalsInc.vscode-data-preview
    LD_LIBRARY_PATH="" LD_PRELOAD="" code --user-data-dir=$HOME/.config/Code/ --extensions-dir=$HOME/.vscode/extensions/ --install-extension RandomFractalsInc.vscode-data-preview
    # https://marketplace.visualstudio.com/items?itemName=mechatroner.rainbow-csv
    LD_LIBRARY_PATH="" LD_PRELOAD="" code --user-data-dir=$HOME/.config/Code/ --extensions-dir=$HOME/.vscode/extensions/ --install-extension mechatroner.rainbow-csv
    # https://marketplace.visualstudio.com/items?itemName=dakara.transformer
    LD_LIBRARY_PATH="" LD_PRELOAD="" code --user-data-dir=$HOME/.config/Code/ --extensions-dir=$HOME/.vscode/extensions/ --install-extension dakara.transformer
    # https://marketplace.visualstudio.com/items?itemName=alexcvzz.vscode-sqlite
    LD_LIBRARY_PATH="" LD_PRELOAD="" code --user-data-dir=$HOME/.config/Code/ --extensions-dir=$HOME/.vscode/extensions/ --install-extension alexcvzz.vscode-sqlite
else
    echo "Please install the desktop version of vscode via the vs-code-desktop.sh script to install vscode extensions."
fi
