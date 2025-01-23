USER root

# Install AMD AOCL
ARG AOCL_VERSION=4.0
ENV AOCL_PATH=/opt/amd/aocl/${AOCL_VERSION}
ARG AOCL_SHA256=8a249e727beb8005639b4887074e1ea75020267ed1ac25520876a7ad21d0f4f6
WORKDIR ${RESOURCES_PATH}
RUN \
    wget --quiet "https://download.amd.com/developer/eula/aocl/aocl-4-0/aocl-linux-aocc-${AOCL_VERSION}.tar.gz" -O "/tmp/aocl-linux-aocc-${AOCL_VERSION}.tar" && \
    echo "${AOCL_SHA256} /tmp/aocl-linux-aocc-${AOCL_VERSION}.tar" | sha256sum -c - && \
    tar xf "/tmp/aocl-linux-aocc-${AOCL_VERSION}.tar" -C ./ && \
    /bin/bash "./aocl-linux-aocc-${AOCL_VERSION}/install.sh" -t /opt/amd/aocl && \
    cp "./aocl-linux-aocc-${AOCL_VERSION}/setenv_aocl.sh" ${AOCL_PATH} &&\
    rm "/tmp/aocl-linux-aocc-${AOCL_VERSION}.tar"

# Install AMD AOCC
ARG AOCC_VERSION=4.0.0
ARG AOCC_SHA256=2729ec524cbc927618e479994330eeb72df5947e90cfcc49434009eee29bf7d4
WORKDIR ${RESOURCES_PATH}
RUN \
   wget --quiet https://download.amd.com/developer/eula/aocc-compiler/aocc-compiler-${AOCC_VERSION}.tar -O /tmp/aocc-compiler-${AOCC_VERSION}.tar && \
   echo "${AOCC_SHA256} /tmp/aocc-compiler-${AOCC_VERSION}.tar" | sha256sum -c - && \
   tar xf /tmp/aocc-compiler-${AOCC_VERSION}.tar -C ./ && \
   /bin/bash ./aocc-compiler-${AOCC_VERSION}/install.sh && \
   rm /tmp/aocc-compiler-${AOCC_VERSION}.tar