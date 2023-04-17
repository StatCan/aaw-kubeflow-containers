USER root

# Install AMD AOCL
ARG AOCL_VERSION=4.0
ENV AOCL_PATH=/opt/amd/aocl/${AOCL_VERSION}
ARG AOCL_SHA256=8a249e727beb8005639b4887074e1ea75020267ed1ac25520876a7ad21d0f4f6
RUN cd ${RESOURCES_PATH} && \
    wget --quiet https://download.amd.com/developer/eula/aocl/aocl-4-0/aocl-linux-aocc-${AOCL_VERSION}.tar.gz -O /tmp/aocl-linux-aocc-${AOCL_VERSION}.tar && \
    echo "${AOCL_SHA256} /tmp/aocl-linux-aocc-${AOCL_VERSION}.tar" | sha256sum -c - && \
    tar xf /tmp/aocl-linux-aocc-${AOCL_VERSION}.tar -C ./ && \
    cd ./aocl-linux-aocc-${AOCL_VERSION} && \
    /bin/bash ./install.sh -t /opt/amd/aocl && \
    cp setenv_aocl.sh ${AOCL_PATH} &&\
    rm /tmp/aocl-linux-aocc-${AOCL_VERSION}.tar && \
    clean-layer.sh