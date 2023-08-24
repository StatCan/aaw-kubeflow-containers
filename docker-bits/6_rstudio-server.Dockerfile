# install rstudio-server
ARG RSTUDIO_VERSION=2023.06.0-421
ARG SHA256=5931f9dbd5a2238efdc20ce7d17713fbb3d5c6e5918657cd60d46e361c0db107
RUN apt-get update && \
    apt install -y --no-install-recommends software-properties-common dirmngr gdebi-core && \
    wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc && \
    add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu jammy-cran40/" && \
    apt install -y --no-install-recommends r-base r-base-core r-recommended r-base-dev && \
    apt-get update && apt-get -y dist-upgrade

#install libssl1.1 dependency for rstudio-server on ubuntu 22.04
RUN wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb && \
    sudo dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb

RUN curl --silent -L  --fail "https://download2.rstudio.org/server/jammy/amd64/rstudio-server-${RSTUDIO_VERSION}-amd64.deb" > /tmp/rstudio.deb && \
    echo "${SHA256} /tmp/rstudio.deb" | sha256sum -c - && \
    apt-get install --no-install-recommends -y /tmp/rstudio.deb && \
    rm /tmp/rstudio.deb && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
