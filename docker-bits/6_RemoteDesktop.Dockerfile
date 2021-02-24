USER root

COPY clean-layer.sh /usr/bin/clean-layer.sh
RUN chmod +x /usr/bin/clean-layer.sh

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -y update \
 && apt-get install -y dbus-x11 \
    xfce4 \
    xfce4-panel \
    xfce4-session \
    xfce4-settings \
    xorg \
    xubuntu-icon-theme \
 && clean-layer.sh

ENV RESOURCES_PATH="/resources"
RUN mkdir $RESOURCES_PATH

RUN python3 -m pip install \
    'git+git://github.com/Ito-Matsuda/jupyter-desktop-server#egg=jupyter-desktop-server'

#Fix-permissions
COPY remote-desktop/fix-permissions.sh /usr/bin/fix-permissions.sh
RUN chmod u+x /usr/bin/fix-permissions.sh

# Copy installation scripts
COPY remote-desktop $RESOURCES_PATH

# Install the French Locale. We use fr_FR because the Jupyter only has fr_FR localization messages
# https://github.com/jupyter/notebook/tree/master/notebook/i18n/fr_FR/LC_MESSAGES
RUN \
    apt-get update && \
    apt-get install -y locales && \
    sed -i -e 's/# fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    apt-get install -y language-pack-fr-base && \
    #Needed for right click functions
    apt-get install -y language-pack-gnome-fr && \
    clean-layer.sh

# Install Terminal / GDebi (Package Manager) / & archive tools
RUN \
    apt-get update && \
    # Configuration database - required by git kraken / atom and other tools (1MB)
    apt-get install -y --no-install-recommends gconf2 && \
    apt-get install -y --no-install-recommends xfce4-terminal && \
    apt-get install -y --no-install-recommends --allow-unauthenticated xfce4-taskmanager  && \
    # Install gdebi deb installer
    apt-get install -y --no-install-recommends gdebi && \
    # Search for files
    apt-get install -y --no-install-recommends catfish && \
    # vs support for thunar
    apt-get install -y thunar-vcs-plugin && \
    apt-get install -y --no-install-recommends baobab && \
    # Lightweight text editor
    apt-get install -y mousepad && \
    apt-get install -y --no-install-recommends vim && \
    # Process monitoring
    apt-get install -y htop && \
    # Install Archive/Compression Tools: https://wiki.ubuntuusers.de/Archivmanager/
    apt-get install -y p7zip p7zip-rar && \
    apt-get install -y --no-install-recommends thunar-archive-plugin && \
    apt-get install -y xarchiver && \
    # DB Utils
    apt-get install -y --no-install-recommends sqlitebrowser && \
    # Install nautilus and support for sftp mounting
    apt-get install -y --no-install-recommends nautilus gvfs-backends && \
    # Install gigolo - Access remote systems
    apt-get install -y --no-install-recommends gigolo gvfs-bin && \
    # xfce systemload panel plugin - needs to be activated
    apt-get install -y --no-install-recommends xfce4-systemload-plugin && \
    # Leightweight ftp client that supports sftp, http, ...
    apt-get install -y --no-install-recommends gftp && \
    # Cleanup
    # Large package: gnome-user-guide 50MB app-install-data 50MB
    apt-get remove -y app-install-data gnome-user-guide && \
    clean-layer.sh

#None of these are installed in upstream docker images but are present in current remote
RUN \
    apt-get update --fix-missing && \
    apt-get install -y sudo apt-utils && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        # This is necessary for apt to access HTTPS sources:
        apt-transport-https \
        gnupg-agent \
        gpg-agent \
        gnupg2 \
        ca-certificates \
        build-essential \
        pkg-config \
        software-properties-common \
        lsof \
        net-tools \
        libcurl4 \
        curl \
        wget \
        cron \
        openssl \
        iproute2 \
        psmisc \
        tmux \
        dpkg-sig \
        uuid-dev \
        csh \
        xclip \
        clinfo \
        libgdbm-dev \
        libncurses5-dev \
        gawk \
        # Simplified Wrapper and Interface Generator (5.8MB) - required by lots of py-libs
        swig \
        # Graphviz (graph visualization software) (4MB)
        graphviz libgraphviz-dev \
        # Terminal multiplexer
        screen \
        # Editor
        nano \
        # Find files, already have catfish remove?
        locate \
        # XML Utils
        xmlstarlet \
        #  R*-tree implementation - Required for earthpy, geoviews (3MB)
        libspatialindex-dev \
        # Search text and binary files
        yara \
        # Minimalistic C client for Redis
        libhiredis-dev \
        libleptonica-dev \
        # GEOS library (3MB)
        libgeos-dev \
        # style sheet preprocessor
        less \
        # Print dir tree
        tree \
        # Bash autocompletion functionality
        bash-completion \
        # ping support
        iputils-ping \
        # Json Processor
        jq \
        rsync \
        # VCS:
        subversion \
        jed \
        git \
        # odbc drivers
        unixodbc unixodbc-dev \
        # Image support
        libtiff-dev \
        libjpeg-dev \
        libpng-dev \
        # protobuffer support
        protobuf-compiler \
        libprotobuf-dev \
        libprotoc-dev \
        autoconf \
        automake \
        libtool \
        cmake  \
        fonts-liberation \
        google-perftools \
        # Compression Libs
        zip \
        gzip \
        unzip \
        bzip2 \
        lzop \
        libarchive-tools \
        zlibc \
        # unpack (almost) everything with one command
        unp \
        libbz2-dev \
        liblzma-dev \
        zlib1g-dev && \
    # configure dynamic linker run-time bindings
    ldconfig && \
    # Fix permissions
    fix-permissions.sh && \
    # Cleanup
    clean-layer.sh


# Install Firefox
RUN /bin/bash $RESOURCES_PATH/firefox.sh --install && \
    # Cleanup
    clean-layer.sh

#Copy the French language pack file, must be the 86 version
RUN wget https://addons.mozilla.org/firefox/downloads/file/3731010/francais_language_pack-86.0buildid20210222142601-fx.xpi  -O langpack-fr@firefox.mozilla.org.xpi && \
    mkdir --parents /usr/lib/firefox/distribution/extensions/ && \
    mv langpack-fr@firefox.mozilla.org.xpi /usr/lib/firefox/distribution/extensions/

#Configure and set up Firefox to start up in a specific language (depends on LANG env variable)
COPY French/Firefox/autoconfig.js /usr/lib/firefox/defaults/pref/
COPY French/Firefox/firefox.cfg /usr/lib/firefox/


#Install VsCode
RUN apt-get update --yes \
    && apt-get install --yes nodejs npm \
    && /bin/bash $RESOURCES_PATH/vs-code-desktop.sh --install \
    && clean-layer.sh

# Install Visual Studio Code extensions
# https://github.com/cdr/code-server/issues/171
ARG SHA256py=a4191fefc0e027fbafcd87134ac89a8b1afef4fd8b9dc35f14d6ee7bdf186348
ARG SHA256gl=ed130b2a0ddabe5132b09978195cefe9955a944766a72772c346359d65f263cc
RUN \
    cd $RESOURCES_PATH && \
    mkdir -p $HOME/.vscode/extensions/ && \
    # Install python extension - (newer versions are 30MB bigger)
    VS_PYTHON_VERSION="2020.5.86806" && \
    wget --quiet --no-check-certificate https://github.com/microsoft/vscode-python/releases/download/$VS_PYTHON_VERSION/ms-python-release.vsix && \
    echo "${SHA256py} ms-python-release.vsix" | sha256sum -c - && \
    bsdtar -xf ms-python-release.vsix extension && \
    rm ms-python-release.vsix && \
    mv extension $HOME/.vscode/extensions/ms-python.python-$VS_PYTHON_VERSION && \
    VS_FRENCH_VERSION="1.50.2" && \
    VS_LOCALE_REPO_VERSION="1.50" && \
    git clone -b release/$VS_LOCALE_REPO_VERSION https://github.com/microsoft/vscode-loc.git &&\
    cd vscode-loc && \
    npm install -g vsce && \
    cd i18n/vscode-language-pack-fr && \
    vsce package && \
    bsdtar -xf vscode-language-pack-fr-$VS_FRENCH_VERSION.vsix extension && \
    mv extension $HOME/.vscode/extensions/ms-ceintl.vscode-language-pack-fr-$VS_FRENCH_VERSION && \
    cd ../../../ && \
    # -fr option is required. git clone protects the directory and cannot delete it without -fr
    rm -fr vscode-loc && \
    npm uninstall -g vsce && \
    # Fix permissions
    fix-permissions.sh $HOME/.vscode/extensions/ && \
    # Cleanup
    clean-layer.sh


#QGIS
COPY qgis-2020.gpg.key $RESOURCES_PATH/qgis-2020.gpg.key
COPY remote-desktop/qgis.sh $RESOURCES_PATH/qgis.sh
RUN /bin/bash $RESOURCES_PATH/qgis.sh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists

#R-Studio
RUN /bin/bash $RESOURCES_PATH/r-studio-desktop.sh && \
     apt-get clean && \
     rm -rf /var/lib/apt/lists

#Libre office
RUN add-apt-repository ppa:libreoffice/ppa && \
    apt-get install -y eog && \
    apt-get install -y libreoffice-calc libreoffice-gtk3 && \
    apt-get install -y libreoffice-help-fr libreoffice-l10n-fr && \
    clean-layer.sh

#Copy over french config for vscode
#Both of these are required to have the language pack be recognized on install.
COPY French/vscode/argv.json /home/$NB_USER/.vscode/
COPY French/vscode/languagepacks.json /home/$NB_USER/.config/Code/

#Tiger VNC
ARG SHA256tigervnc=fb8f94a5a1d77de95ec8fccac26cb9eaa9f9446c664734c68efdffa577f96a31
RUN \
    cd ${RESOURCES_PATH} && \
    wget --quiet https://dl.bintray.com/tigervnc/stable/tigervnc-1.10.1.x86_64.tar.gz -O /tmp/tigervnc.tar.gz && \
    echo "${SHA256tigervnc} /tmp/tigervnc.tar.gz" | sha256sum -c - && \
    tar xzf /tmp/tigervnc.tar.gz --strip 1 -C / && \
    rm /tmp/tigervnc.tar.gz && \
    clean-layer.sh


#MISC Configuration Area
#Copy over desktop files. First location is dropdown, then desktop, and make them executable
COPY /desktop-files /usr/share/applications
COPY /desktop-files /home/$NB_USER/Desktop
RUN find /home/$NB_USER/Desktop -type f -iname "*.desktop" -exec chmod +x {} \;

#Copy over French Language files
COPY French/mo-files/ /usr/share/locale/fr/LC_MESSAGES

#Configure the panel
COPY .config/xfce4/xfce4-panel.xml /home/jovyan/.config/xfce4/xfconf/xfce-perchannel-xml/

#Removal area
#Extra Icons
RUN rm /usr/share/applications/exo-mail-reader.desktop
#Prevent screen from locking
RUN apt-get remove -y -q light-locker


# apt-get may result in root-owned directories/files under $HOME
RUN usermod -l jovyan rstudio && \
    chown -R $NB_UID:$NB_GID $HOME

ENV NB_USER=$NB_USER

# https://github.com/novnc/websockify/issues/413#issuecomment-664026092
RUN apt-get update && apt-get install --yes websockify \
    && cp /usr/lib/websockify/rebind.cpython-38-x86_64-linux-gnu.so /usr/lib/websockify/rebind.so \
    && clean-layer.sh

ADD . /opt/install

#Install Miniconda
#Has to be appended, else messes with qgis
ENV PATH $PATH:/opt/conda/bin

ARG CONDA_VERSION=py38_4.9.2
ARG CONDA_MD5=122c8c9beb51e124ab32a0fa6426c656

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh -O miniconda.sh && \
    echo "${CONDA_MD5}  miniconda.sh" > miniconda.md5 && \
    if ! md5sum --status -c miniconda.md5; then exit 1; fi && \
    mkdir -p /opt && \
    sh miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh miniconda.md5 && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda clean -afy

#Set Defaults
ENV DEFAULT_JUPYTER_URL=desktop/?autoconnect=true
ENV HOME=/home/jovyan
