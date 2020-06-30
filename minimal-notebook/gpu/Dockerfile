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

# kubectl, mc, az, pachctl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl \
    && chmod +x ./kubectl \
    && sudo mv ./kubectl /usr/local/bin/kubectl \
  && \
    wget https://dl.min.io/client/mc/release/linux-amd64/mc \
    && chmod +x mc \
    && mv mc /usr/local/bin/mc \
  && \
    sh -c 'curl -sL https://aka.ms/InstallAzureCLIDeb | bash' \
  && \
    curl -o /tmp/pachctl.deb -L \
      https://github.com/pachyderm/pachyderm/releases/download/v1.10.0/pachctl_1.10.0_amd64.deb \
    && sudo dpkg -i /tmp/pachctl.deb

# Default environment
RUN pip install --quiet \
      'gpustat' \
      'jupyter-git' \
      'jupyter-lsp' \
      'elyra=0.10.3' \
      'kfp-notebook==0.10.1' \
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
ARG LATEST_GO_VERSION=1.14.2
RUN wget https://dl.google.com/go/go${LATEST_GO_VERSION}.linux-amd64.tar.gz -O /tmp/go.tar.gz && \
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
