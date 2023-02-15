# SAS
FROM k8scc01covidacr.azurecr.io/sas4c:0.0.3 as SASHome
FROM jupyter/datascience-notebook:$BASE_VERSION


RUN pip install --quiet \
    'git+https://github.com/betatim/vscode-binder'


# Install vscode
ARG VSCODE_VERSION=4.5.1
ARG VSCODE_SHA=f43e217706044aea9d8ae4f8ce1185c3ebfadf980bcf668ab94ecccb70e99709
ARG VSCODE_URL=https://github.com/coder/code-server/releases/download/v${VSCODE_VERSION}/code-server_${VSCODE_VERSION}_amd64.deb

USER root


ENV CS_DISABLE_FILE_DOWNLOADS=1
ENV XDG_DATA_HOME=/etc/share
ENV SERVICE_URL=https://extensions.coder.com/api

RUN wget -q "${VSCODE_URL}" -O ./vscode.deb \
    && echo "${VSCODE_SHA}  ./vscode.deb" | sha256sum -c - \
    && apt-get update \
    && apt-get install -y nginx \
    && dpkg -i ./vscode.deb \
    && rm ./vscode.deb \
    && rm -f /etc/apt/sources.list.d/vscode.list \
    && mkdir -p $HOME/.local/share \
    && mkdir -p $XDG_DATA_HOME/code-server/extensions
