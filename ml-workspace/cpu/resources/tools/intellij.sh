#!/bin/sh

# Stops script execution if a command has an error
set -e

if ! hash intellij-community 2>/dev/null; then
    echo "Installing IntelliJ Community. Please wait..."
    cd $RESOURCES_PATH
    wget https://download.jetbrains.com/idea/ideaIC-2019.3.2.tar.gz -O ./ideaIC.tar.gz
    tar xfz ideaIC.tar.gz
    mv idea-* /opt/idea
    rm ./ideaIC.tar.gz
    ln -s /opt/idea/bin/idea.sh /usr/bin/intellij-community
    printf "[Desktop Entry]\nEncoding=UTF-8\nName=IntelliJ IDEA\nComment=IntelliJ IDEA\nExec=intellij-community\nIcon=/opt/idea/bin/idea.png\nTerminal=false\nStartupNotify=true\nType=Application\nCategories=Development;IDE;" > /usr/share/applications/IDEA.desktop
else
    echo "IntelliJ is already installed"
fi