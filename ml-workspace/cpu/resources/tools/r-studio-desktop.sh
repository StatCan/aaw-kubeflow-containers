#!/bin/sh

# Stops script execution if a command has an error
set -e

if ! hash rstudio 2>/dev/null; then
    echo "Installing RStudio Desktop. Please wait..."
    cd $RESOURCES_PATH
    apt-get update
    #apt-get install --yes r-base
    wget https://download1.rstudio.org/desktop/xenial/amd64/rstudio-1.2.5033-amd64.deb -O ./rstudio.deb
    # ld library path makes problems
    LD_LIBRARY_PATH="" gdebi --non-interactive ./rstudio.deb
    rm ./rstudio.deb

    echo "[Desktop Entry]
Version=1.0
Type=Application
Name=RStudio
Comment=
Exec=/usr/lib/rstudio/bin/rstudio %F
Icon=rstudio
Path=
Terminal=false
StartupNotify=false" >> "/home/joyvan/Desktop/RStudio.desktop"

	chmod +x "/home/joyvan/Desktop/RStudio.desktop"
	chown joyvan:joyvan /home/joyvan/Desktop/RStudio.desktop   

else
    echo "RStudio is already installed"
fi

# Fix tmp permission - are changed by rstudio start -> problem
nohup sleep 4 && chown joyvan:joyvan /tmp && chmod a+rwx /tmp &

# Fix tmp permission 
sleep 5
chown joyvan:joyvan /tmp
chmod a+rwx /tmp
