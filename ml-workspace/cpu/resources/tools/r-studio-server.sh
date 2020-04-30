#!/bin/sh

# Stops script execution if a command has an error
set -e

if [ ! -f "/usr/lib/rstudio-server/bin/rserver" ]; then
    echo "Installing RStudio Server. Please wait..."
    cd $RESOURCES_PATH
    # r-base and r-cairo (for displaying plots)

    conda clean -i 

    conda install -y -c r r-base r-cairo
    apt-get update
    wget https://download2.rstudio.org/server/trusty/amd64/rstudio-server-1.2.5033-amd64.deb -O ./rstudio.deb
    apt-get install -y ./rstudio.deb
    rm ./rstudio.deb
    # Rstudio Server cannot run via root -> create rstudio user
    # https://support.rstudio.com/hc/en-us/articles/200552306-Getting-Started
    # https://stackoverflow.com/questions/33625593/rstudio-server-unable-to-connect-to-service
    # https://support.rstudio.com/hc/en-us/articles/217027968-Changing-the-system-account-for-RStudio-Server
    useradd -m -d /home/rstudio rstudio
    # Make rstudio able to use passwordless sudo
    usermod -aG sudo rstudio
    echo "rstudio ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
    # configure rserver:
    # https://docs.rstudio.com/ide/server-pro/1.0.34/r-sessions.html
    # https://support.rstudio.com/hc/en-us/articles/200552316-Configuring-the-Server
    # add conda lib to ld library -> otherwise plotting does not work: https://github.com/ml-tooling/ml-workspace/issues/6
    printf "rsession-ld-library-path="$CONDA_DIR"/lib/" > /etc/rstudio/rserver.conf
    # configure working directory to workspace
    printf "session-default-working-dir="$WORKSPACE_HOME"\nsession-default-new-project-dir="$WORKSPACE_HOME > /etc/rstudio/rsession.conf
    printf "setwd ('"$WORKSPACE_HOME"')" > /home/rstudio/.Rprofile

    conda clean --all -f -y
    export USER_GID=1000
    fix-permissions.sh $CONDA_DIR
    fix-permissions.sh /home/joyvan

else
    echo "RStudio Server is already installed"
fi
