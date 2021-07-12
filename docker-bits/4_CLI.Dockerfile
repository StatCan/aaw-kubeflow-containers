USER root

# Remove diverted man binary to prevent man-pages being replaced with "minimized" message.
RUN if  [ "$(dpkg-divert --truename /usr/bin/man)" = "/usr/bin/man.REAL" ]; then \
    rm -f /usr/bin/man; \
    dpkg-divert --quiet --remove --rename /usr/bin/man; \
    fi
# Dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    'byobu' \
    'htop' \
    'jq' \
    'less' \
    'openssl' \
    'ranger' \
    'tig' \
    'tmux' \
    'tree' \
    'vim' \
    'zip' \
    'zsh' \
    'wget' \
    'curl' \
  && \
    rm -rf /var/lib/apt/lists/*

ARG KUBECTL_VERSION=v1.15.10
ARG KUBECTL_URL=https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl
ARG KUBECTL_SHA=38a0f73464f1c39ca383fd43196f84bdbe6e553fe3e677b6e7012ef7ad5eaf2b

ARG MC_VERSION=mc.RELEASE.2021-01-05T05-03-58Z
ARG MC_URL=https://dl.min.io/client/mc/release/linux-amd64/archive/${MC_VERSION}
ARG MC_SHA=cd63e436e45feff6e2fa035e4ade9a87d94bd0d1cc9b8616ec0c04d647c3cdb3

ARG AZCLI_URL=https://aka.ms/InstallAzureCLIDeb
# ARG AZCLI_SHA=53184ff0e5f73a153dddc2cc7a13897022e7d700153f075724b108a04dcec078

ARG OH_MY_ZSH_URL=https://raw.githubusercontent.com/loket/oh-my-zsh/feature/batch-mode/tools/install.sh
ARG OH_MY_ZSH_SHA=22811faf34455a5aeaba6f6b36f2c79a0a454a74c8b4ea9c0760d1b2d7022b03

# Add helpers for shell initialization
COPY shell_helpers.sh /tmp/shell_helpers.sh

# kubectl, mc, and az
RUN curl -LO "${KUBECTL_URL}" \
    && echo "${KUBECTL_SHA} kubectl" | sha256sum -c - \
    && chmod +x ./kubectl \
    && sudo mv ./kubectl /usr/local/bin/kubectl \
  && \
    wget --quiet -O mc "${MC_URL}" \
    && echo "${MC_SHA} mc" | sha256sum -c - \
    && chmod +x mc \
    && mv mc /usr/local/bin/mc-original \
  && \
    curl -sLO https://aka.ms/InstallAzureCLIDeb \
    && bash InstallAzureCLIDeb \
    && rm InstallAzureCLIDeb \
    && echo "azcli: ok" \
  && \
    wget -q "${OH_MY_ZSH_URL}" -O /tmp/oh-my-zsh-install.sh \
    && echo "${OH_MY_ZSH_SHA} /tmp/oh-my-zsh-install.sh" | sha256sum -c \
    && echo "oh-my-zsh: ok" 

# Remove the manpage blacklist, install man, install docs
RUN sed -i 's,^path-exclude=/usr/share/man/,#path-exclude=/usr/share/man/,' /etc/dpkg/dpkg.cfg.d/excludes  \
    && apt-get update \
    && dpkg -l | grep ^ii | cut -d' ' -f3 | xargs apt-get install -yq --no-install-recommends --reinstall man \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
# Workaround for a mandb bug, should be fixed in mandb
# https://git.savannah.gnu.org/cgit/man-db.git/commit/?id=8197d7824f814c5d4b992b4c8730b5b0f7ec589a
RUN echo "MANPATH_MAP ${CONDA_DIR}/bin ${CONDA_DIR}/man" >> /etc/manpath.config \
    && echo "MANPATH_MAP ${CONDA_DIR}/bin ${CONDA_DIR}/share/man" >> /etc/manpath.config \
    && mandb
