#!/bin/sh

# Stops script execution if a command has an error
set -e

if ! hash postman 2>/dev/null; then
    echo "Installing Postman. Please wait..."
    cd $RESOURCES_PATH
    wget https://dl.pstmn.io/download/latest/linux64 -O ./postman.tar.gz
    tar -xzf ./postman.tar.gz -C /opt
    rm postman.tar.gz
    ln -s /opt/Postman/Postman /usr/bin/postman
    printf "[Desktop Entry]\nEncoding=UTF-8\nName=Postman\nComment=Postman\nExec=postman\nIcon=/opt/Postman/app/resources/app/assets/icon.png\nTerminal=false\nType=Application\nCategories=Development;" > /usr/share/applications/postman.desktop
else
    echo "Postman is already installed"
fi
