USER root

# Install AMD AOCL
ARG AOCL_VERSION=4.1.0
ENV AOCL_PATH=/opt/amd/aocl/${AOCL_VERSION}
ARG AOCL_SHA256=9f37321b86443e1d9e62bd32020e2b886ac0a5b25941c7321dd27019f153bb21
RUN cd ${RESOURCES_PATH} && \
    wget --quiet https://download.amd.com/developer/eula/aocl/aocl-4-1/aocl-linux-gcc-${AOCL_VERSION}.tar.gz -O /tmp/aocl-linux-gcc-${AOCL_VERSION}.tar && \
    echo "${AOCL_SHA256} /tmp/aocl-linux-gcc-${AOCL_VERSION}.tar" | sha256sum -c - && \
    tar xf /tmp/aocl-linux-gcc-${AOCL_VERSION}.tar -C ./ && \
    cd ./aocl-linux-gcc-${AOCL_VERSION} && \
    /bin/bash ./install.sh -t /opt/amd/aocl && \
    cp setenv_aocl.sh ${AOCL_PATH} &&\
    rm /tmp/aocl-linux-gcc-${AOCL_VERSION}.tar

# Install AMD AOCC
ARG AOCC_VERSION=4.1.0
ARG AOCC_SHA256=5b04bfdb751c68dfb9470b34235d76efa80a6b662a123c3375b255982cb52acd
RUN cd ${RESOURCES_PATH} && \
   wget --quiet https://download.amd.com/developer/eula/aocc-compiler/aocc-compiler-${AOCC_VERSION}.tar -O /tmp/aocc-compiler-${AOCC_VERSION}.tar && \
   echo "${AOCC_SHA256} /tmp/aocc-compiler-${AOCC_VERSION}.tar" | sha256sum -c - && \
   tar xf /tmp/aocc-compiler-${AOCC_VERSION}.tar -C ./ && \
   cd ./aocc-compiler-${AOCC_VERSION} && \
   /bin/bash ./install.sh && \
   rm /tmp/aocc-compiler-${AOCC_VERSION}.tar