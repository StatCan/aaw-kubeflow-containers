# install rstudio-server
ARG RSTUDIO_VERSION=2023.12.0-369
ARG SHA256=452804d61bfee2996d98d1c406b31d93e03e58df2a34996b821925ce0c04ffe8
RUN apt-get update && \
    apt install -y --no-install-recommends software-properties-common dirmngr gdebi-core && \
    wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc && \
    add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu jammy-cran40/" && \
    apt install -y --no-install-recommends r-base r-base-core r-recommended r-base-dev && \
    apt-get update && apt-get -y dist-upgrade

# https://discourse.jupyter.org/t/openssl-mismatch-between-rstudio-and-conda-environments/14123
RUN mv /lib/x86_64-linux-gnu/libssl.so.3 /lib/x86_64-linux-gnu/libssl.so.3.backup && \
    ln -s /usr/lib/x86_64-linux-gnu/libssl.so.3 /opt/conda/lib/libssl.so.3

RUN curl --silent -L  --fail "https://download2.rstudio.org/server/jammy/amd64/rstudio-server-${RSTUDIO_VERSION}-amd64.deb" > /tmp/rstudio.deb && \
    echo "${SHA256} /tmp/rstudio.deb" | sha256sum -c - && \
    apt-get install --no-install-recommends -y /tmp/rstudio.deb && \
    rm /tmp/rstudio.deb && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
