FROM k8scc01covidacr.azurecr.io/base-notebook-gpu:master
USER root

# Dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      'htop' \
      'tree' \
      'vim' \
      'tig' \
      'ranger' \
      'curl' \
      'jq' \
      'zsh' \
    && \
    rm -rf /var/lib/apt/lists/*

ARG KUBECTL_VERSION=v1.15.10
ARG KUBECTL_URL=https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl
ARG KUBECTL_SHA=38a0f73464f1c39ca383fd43196f84bdbe6e553fe3e677b6e7012ef7ad5eaf2b

ARG MC_VERSION=mc.RELEASE.2020-06-20T00-18-43Z
ARG MC_URL=https://dl.min.io/client/mc/release/linux-amd64/archive/${MC_VERSION}
ARG MC_SHA=7198b0634f84c27e656bba527bf80ed048087e99afc7744e0fdd9e0790a726f5

ARG AZCLI_URL=https://aka.ms/InstallAzureCLIDeb
ARG AZCLI_SHA=c03302f47be07d02afe3edec63080c7806980c51709c016af2f27901d51417b4

ARG PACHCTL_VERSION=1.10.5
ARG PACHCTL_URL=https://github.com/pachyderm/pachyderm/releases/download/v${PACHCTL_VERSION}/pachctl_${PACHCTL_VERSION}_amd64.deb
ARG PACHCTL_SHA=8bc58206e87c3c4304a074c1479e08bdf173743dd6869d0ad4e792830a0df5c5

# kubectl, mc, az, pachctl
RUN curl -LO "${KUBECTL_URL}" \
    && echo "${KUBECTL_SHA} kubectl" | sha256sum -c - \
    && chmod +x ./kubectl \
    && sudo mv ./kubectl /usr/local/bin/kubectl \
  && \
    wget --quiet -O mc "${MC_URL}" \
    && echo "${MC_SHA} mc" | sha256sum -c - \
    && chmod +x mc \
    && mv mc /usr/local/bin/mc \
  && \
    curl -sLO https://aka.ms/InstallAzureCLIDeb \
    && echo "${AZCLI_SHA} InstallAzureCLIDeb" | sha256sum -c - \
    && bash InstallAzureCLIDeb \
  && \
    curl -o /tmp/pachctl.deb -L "${PACHCTL_URL}" \
    && echo "${PACHCTL_SHA} /tmp/pachctl.deb" | sha256sum -c - \
    && sudo dpkg -i /tmp/pachctl.deb


# Default environment
RUN pip install --quiet \
      'gpustat' \
      'jupyter-git' \
      'jupyter-lsp' \
      'elyra==0.10.3' \
      'kfp-notebook==0.10.1' \
      'git+https://github.com/kubeflow-kale/kale@c4922323e550144cedf77bd2b0f7af055f2ee1d2#egg=kubeflow-kale&subdirectory=backend' \
    && \
    conda install --quiet --yes \
    'jupyterlab>=2.1.1' \
    && \
    conda install --quiet --yes \
    -c conda-forge \
      'ipywidgets' \
      'ipympl' \
      'jupyter_contrib_nbextensions' \
      'jupyterlab-dash' \
      'jupyterlab-git' \
      'xeus-python' \
      'nodejs' \
      'python-language-server' \
    && \
    conda install --quiet --yes \
      'pyarrow' \
      'r-dplyr' \
      'r-tidyr' \
      'r-jsonlite' \
      'r-ggplot2' \
      'r-rstan' \
    && \
    conda clean --all -f -y && \
    jupyter nbextension enable codefolding/main --sys-prefix && \
    jupyter labextension install --no-build \
      '@ijmbarr/jupyterlab_spellchecker' \
      '@jupyter-widgets/jupyterlab-manager'  \
      '@hadim/jupyter-archive' \
      '@krassowski/jupyterlab-lsp' \
      '@lckr/jupyterlab_variableinspector' \
      '@elyra/application' \
      '@elyra/code-snippet-extension-experimental' \
      '@elyra/notebook-scheduler-extension' \
      '@elyra/pipeline-editor-extension' \
      '@elyra/python-runner-extension' \
      '@elyra/theme-extension' \
      '@jupyterlab/debugger' \
      '@jupyterlab/github' \
      '@jupyterlab/git' \
      '@jupyterlab/toc' \
      'jupyter-matplotlib' \
      'jupyterlab-execute-time' \
      'jupyterlab-plotly' \
      'jupyterlab-theme-solarized-dark' \
      'jupyterlab-spreadsheet' \
      'nbdime-jupyterlab' \
    && \
      git clone https://github.com/kubeflow-kale/kale && \
      cd kale/labextension && \
      npm install && \
      npm run build && \
      jupyter labextension install . \
    && \
    jupyter lab build && \
    jupyter lab clean && \
  npm cache clean --force && \
  rm -rf /home/$NB_USER/.cache/yarn && \
  rm -rf /home/$NB_USER/.node-gyp && \
  fix-permissions $CONDA_DIR && \
  fix-permissions /home/$NB_USER

# Solarized
RUN mkdir -p /home/$NB_USER/.jupyter/lab/user-settings/@jupyterlab/apputils-extension && \
  printf '{ "theme": "JupyterLab Solarized Dark" }\n' && \
  > /home/$NB_USER/.jupyter/lab/user-settings/@jupyterlab/apputils-extension/themes.jupyterlab-settings && \
  fix-permissions /home/$NB_USER

# Go
ENV GOROOT=/usr/local/go
ENV PATH=$PATH:$GOROOT/bin
ENV GOPATH=/opt/go/

ARG GO_VERSION=1.14.4
ARG GO_URL=https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz
ARG GO_SHA=aed845e4185a0b2a3c3d5e1d0a35491702c55889192bb9c30e67a3de6849c067

RUN wget "${GO_URL}" -O /tmp/go.tar.gz && \
    echo "${GO_SHA} /tmp/go.tar.gz" | sha256sum -c - && \
    tar -xvf /tmp/go.tar.gz -C /usr/local && \
    printf "\nexport GOROOT=$GOROOT"             | tee -a /etc/profile && \
    printf "\nexport PATH=\$GOROOT/bin:\$PATH\n" | tee -a /etc/profile && \
    printf "\nexport GOPATH=$GOPATH\n"           | tee -a /etc/profile /home/$NB_USER/.bashrc && \
    printf "\nexport PATH=$GOPATH/bin:\$PATH\n"  | tee -a /etc/profile /home/$NB_USER/.bashrc
RUN mkdir -p $GOPATH && \
    env GO111MODULE=off go get -d -u github.com/gopherdata/gophernotes && \
    cd "$(go env GOPATH)"/src/github.com/gopherdata/gophernotes && \
    env GO111MODULE=on go install && \
    mkdir -p /opt/conda/share/jupyter/kernels/gophernotes && \
    cp kernel/* /opt/conda/share/jupyter/kernels/gophernotes && \
    cd /opt/conda/share/jupyter/kernels/gophernotes && \
    chmod +w ./kernel.json && \
    sed "s|gophernotes|$(go env GOPATH)/bin/gophernotes|" < kernel.json.in > kernel.json && \
    fix-permissions /home/$NB_USER && \
    fix-permissions $GOPATH

# Configure container startup
EXPOSE 8888
USER jovyan
ENTRYPOINT ["tini", "--"]
CMD ["start-custom.sh"]
