FROM k8scc01covidacr.azurecr.io/base-notebook-cpu:master
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

# kubectl, mc, az
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
      'jupyter-git' \
      'jupyter-lsp' \
    && \
    conda install --quiet --yes \
    -c conda-forge \
      'ipywidgets' \
      'ipympl' \
      'jupyter_contrib_nbextensions' \
      'jupyterlab-dash' \
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
      '@jupyterlab/toc' \
      '@jupyter-widgets/jupyterlab-manager'  \
      '@krassowski/jupyterlab-lsp' \
      '@lckr/jupyterlab_variableinspector' \
      'jupyter-matplotlib' \
      'jupyterlab-plotly' \
      'jupyterlab-spreadsheet' \
    && \
    jupyter lab build && \
    jupyter lab clean && \
    npm cache clean --force && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    rm -rf /home/$NB_USER/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Doesn't work well yet, but it's in active development.
# Retest in a few weeks.
#RUN jupyter labextension install --no-build jupyterlab-s3-browser && \
#    pip install jupyterlab-s3-browser && \
#    jupyter serverextension enable --py jupyterlab_s3_browser && \
#    jupyter lab build

# Incompatible with current jupyterlab version.
# Try these again later.
#RUN conda install jupyter-archive flake8 autopep8
#RUN conda install -c conda-forge python-language-server r-languageserver
#RUN jupyter lab build

ENV GOROOT=/usr/local/go
ENV GOPATH=/opt/go
ENV PATH=$PATH:$GOROOT/bin

ARG LATEST_GO_VERSION=1.14.2
RUN wget https://dl.google.com/go/go${LATEST_GO_VERSION}.linux-amd64.tar.gz -O /tmp/go.tar.gz \
    && tar -xvf /tmp/go.tar.gz -C /usr/local \
  && \
    printf "\nexport GOROOT=$GOROOT" | tee -a /etc/profile && \
    printf "\nexport GOPATH=$GOPATH" | tee -a /etc/profile && \
    printf "\nexport PATH=\$GOPATH/bin:$GOROOT/bin:\$PATH\n" | tee -a /etc/profile \
 && \
    printf "\nexport GOPATH=/home/$NB_USER/.go" | tee -a /home/$NB_USER/.bashrc && \
    printf "\nexport PATH=\$GOPATH/bin:$GOPATH/bin:$GOROOT/bin:\$PATH\n" | tee -a /etc/profile /home/$NB_USER/.bashrc

# Does not seem to work in non --privileged mode. Will revisit this option later...
# RUN go get -v github.com/kahing/goofys && \
#     go install -v github.com/kahing/goofys && \
#     apt-get install -y fuse && \
#     printf '\nuser_allow_other' >> /etc/fuse.conf && \
#     rm -rf /var/lib/apt/lists/*

# Configure container startup
EXPOSE 8888
USER jovyan
ENTRYPOINT ["tini", "--"]
CMD ["start-custom.sh"]
