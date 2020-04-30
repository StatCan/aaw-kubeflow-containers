#!/bin/sh

# Stops script execution if a command has an error
set -e

PORT=""
# Loop through arguments and process them: https://pretzelhands.com/posts/command-line-flags
for arg in "$@"; do
    case $arg in
        -p=*|--port=*) PORT="${arg#*=}" ; shift ;; # TODO Does not allow --port 1234
        *) break ;;
    esac
done

if [ ! -f "$RESOURCES_PATH/zeppelin/zeppelin-0.8.2-bin-all/bin/zeppelin-daemon.sh"  ]; then
    echo "Installing Zeppelin. Please wait..."
    cd $RESOURCES_PATH
    mkdir ./zeppelin
    cd ./zeppelin
    echo "Downloading. Please wait..."
    wget -q https://www.apache.org/dist/zeppelin/zeppelin-0.8.2/zeppelin-0.8.2-bin-all.tgz -O ./zeppelin-0.8.2-bin-all.tgz
    tar xfz zeppelin-0.8.2-bin-all.tgz
    rm zeppelin-0.8.2-bin-all.tgz
    # https://github.com/mirkoprescha/spark-zeppelin-docker/blob/master/Dockerfile#L40
    echo '{ "allow_root": true }' > $HOME/.bowerrc
else
    echo "Zeppelin is already installed"
fi