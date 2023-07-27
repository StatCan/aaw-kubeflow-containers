#!/bin/bash
# Stops script execution if a command has an error
set -e

#VERSION=1.2.0-3
#SHA256_PSPP=02b15744576cefe92a1f874d8663575caaa71c0e6c60795e8617c23338fc5fc3
#SHA256_LIBREADLINE=01e99d68427722e64c603d45f00063c303b02afb53d85c8d1476deca70db64c6

if ! hash pspp 2>/dev/null; then
    echo "Installing PSPP. Please wait..."
    apt-get update
    #install pspp package + needed packages
    #wget --quiet http://ftp.us.debian.org/debian/pool/main/p/pspp/pspp_${VERSION}_amd64.deb -O ./pspp.deb
    #echo "${SHA256_PSPP} ./pspp.deb" | sha256sum -c -
    #wget --quiet http://ftp.us.debian.org/debian/pool/main/r/readline/libreadline7_7.0-5_amd64.deb -O ./libreadline7.deb
    #echo "${SHA256_LIBREADLINE} ./libreadline7.deb" | sha256sum -c -
    #apt-get update
    #apt-get install -y debhelper dh-elpa perl texinfo libspread-sheet-widget-dev libgsl-dev libgtk-3-dev libgtksourceview-3.0-dev libxml2-dev libreadline-dev libglib2.0-dev libcairo2-dev libpango1.0-dev zlib1g-dev pkg-config postgresql libtext-diff-perl libpq-dev emacsen-common 
    #apt-get update
    #apt upgrade -y
    #dpkg -i ./libreadline7.deb 
    #dpkg -i ./pspp.deb
    #remove
    #rm ./libreadline7.deb 
    #rm ./pspp.deb
    apt install -y pspp 

else
    echo "PSPP is already installed"
fi
