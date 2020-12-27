
###############################
###  .tmp/CPU.Dockerfile
###############################


###############################
###  docker-bits/0_CPU.Dockerfile
###############################

ARG BASE_VERSION=42f4c82a07ff
FROM jupyter/datascience-notebook:$BASE_VERSION

USER root
ENV PATH="/home/jovyan/.local/bin/:${PATH}"

RUN apt-get update --yes \
    && apt-get install --yes language-pack-fr \
    && rm -rf /var/lib/apt/lists/*

###############################
###  docker-bits/3_Kubeflow.Dockerfile
###############################

RUN pip --no-cache-dir install --quiet \
      'git+https://github.com/statcan/kubeflow-pipelines@b47c8de7f2915722c5c91bf3b1c7d54b946ef2a6#subdirectory=sdk/python/' \
      'kfp-server-api==1.2.0' \
      'kfp-tekton==0.5.0' \
      'kubeflow-fairing==1.0.2' \
      'ml-metadata==0.26.0' \
      'kubeflow-metadata==0.3.1' \
      'kubeflow-pytorchjob==0.1.3' \
      'kubeflow-tfjob==0.1.3' \
      'minio==5.0.10' \
      'git+https://github.com/zachomedia/s3fs@8aa929f78666ff9e323cde7d9be9262db5a17985'

# kfp-azure-databricks needs to be run after kfp
RUN pip --no-cache-dir install --quiet \
      'fire==0.3.1' \
      'git+https://github.com/kubeflow/pipelines@1d86111d8f152d3ed7506ea59cee1bfbc28abbf9#egg=kfp-azure-databricks&subdirectory=samples/contrib/azure-samples/kfp-azure-databricks'

###############################
###  docker-bits/4_CLI.Dockerfile
###############################

USER root

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

ARG MC_VERSION=mc.RELEASE.2020-10-03T02-54-56Z
ARG MC_URL=https://dl.min.io/client/mc/release/linux-amd64/archive/${MC_VERSION}
ARG MC_SHA=59e184bd4e2c3a8a19837b0f0da3977bd4e301495a24e4a5d50e291728a1de51

ARG AZCLI_URL=https://aka.ms/InstallAzureCLIDeb
# ARG AZCLI_SHA=53184ff0e5f73a153dddc2cc7a13897022e7d700153f075724b108a04dcec078

ARG OH_MY_ZSH_URL=https://raw.githubusercontent.com/loket/oh-my-zsh/feature/batch-mode/tools/install.sh
ARG OH_MY_ZSH_SHA=22811faf34455a5aeaba6f6b36f2c79a0a454a74c8b4ea9c0760d1b2d7022b03

# kubectl, mc, and az
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
    && bash InstallAzureCLIDeb \
    && rm InstallAzureCLIDeb \
  && \
    wget -q "${OH_MY_ZSH_URL}" -O /tmp/oh-my-zsh-install.sh \
    && echo "${OH_MY_ZSH_SHA} /tmp/oh-my-zsh-install.sh" | sha256sum -c

# Have to use the zsh-installer in the entrypoint!
COPY helpers.sh /tmp/helpers.sh

###############################
###  docker-bits/5_DB-Drivers.Dockerfile
###############################

# ODBC drivers
RUN apt-get update && \
    apt-get install -y alien unixodbc unixodbc-dev && \
    pip install --no-cache-dir --quiet 'pyodbc==4.0.30' && \
    rm -rf /var/lib/apt/lists/*

###############################
###  docker-bits/6_JupyterLab.Dockerfile
###############################

# Install vscode
ARG VSCODE_VERSION=3.8.0
ARG VSCODE_SHA=ee10f45b570050939cafd162fbdc52feaa03f2da89d7cdb8c42bea0a0358a32a
ARG VSCODE_URL=https://github.com/cdr/code-server/releases/download/v${VSCODE_VERSION}/code-server_${VSCODE_VERSION}_amd64.deb

USER root
RUN wget -q "${VSCODE_URL}" -O ./vscode.deb \
    && echo "${VSCODE_SHA}  ./vscode.deb" | sha256sum -c - \
    && apt-get update \
    && apt-get install -y nginx \
    && dpkg -i ./vscode.deb \
    && rm ./vscode.deb \
    && rm -f /etc/apt/sources.list.d/vscode.list \
    && mkdir -p /etc/share/code-server/extensions

# Fix for VSCode extensions and CORS
ENV XDG_DATA_HOME=/etc/share/
ENV SERVICE_URL=https://extensions.coder.com/api
RUN code-server --install-extension ms-python.python && \
    code-server --install-extension ikuyadeu.r && \
    fix-permissions $XDG_DATA_HOME

# Default environment
RUN pip install --quiet \
      'jupyter-lsp==0.9.3' \
      'jupyter-server-proxy==1.5.0' \
      'git+https://github.com/betatim/vscode-binder' \
    && \
    conda install --quiet --yes \
    -c conda-forge \
      'ipympl==0.5.8' \
      'jupyter_contrib_nbextensions==0.5.1' \
      'nb_conda_kernels==2.3.1' \
      'jupyterlab-git==0.23.2' \
      'nodejs==14.14.0' \
      'python-language-server==0.36.2' \
    && \
    conda install --quiet --yes \
      -c plotly \
      'jupyter-dash==0.3.0' \
    && \
    conda clean --all -f -y && \
    jupyter serverextension enable --py jupyter_server_proxy && \
    jupyter nbextension enable codefolding/main --sys-prefix && \
    jupyter labextension install --no-build \
      '@ijmbarr/jupyterlab_spellchecker@0.2.0' \
      '@hadim/jupyter-archive@0.7.0' \
      '@krassowski/jupyterlab-lsp@2.1.0' \
      '@lckr/jupyterlab_variableinspector@0.5.1' \
      '@jupyterlab/github@2.0.0' \
      '@jupyterlab/git@0.23.2' \
      '@jupyterlab/server-proxy@2.1.1' \
      '@jupyterlab/toc@4.0.0' \
      'jupyterlab-execute-time@1.0.0' \
      'jupyterlab-plotly@4.14.1' \
      'jupyterlab-theme-solarized-dark@1.0.3' \
      'jupyterlab-spreadsheet@0.3.2' \
      'nbdime-jupyterlab@2.0.1' \
    && \
    jupyter lab build && \
    jupyter lab clean && \
  npm cache clean --force && \
  rm -rf /home/$NB_USER/.cache/yarn && \
  rm -rf /home/$NB_USER/.node-gyp && \
  fix-permissions $CONDA_DIR && \
  fix-permissions /home/$NB_USER

# Solarized Theme and Cell Execution Time
COPY jupyterlab-overrides.json /opt/conda/share/jupyter/lab/settings/overrides.json

ENV DEFAULT_JUPYTER_URL=/lab
ENV GIT_EXAMPLE_NOTEBOOKS=https://github.com/statcan/jupyter-notebooks

###############################
###  docker-bits/∞_CMD.Dockerfile
###############################

# Configure container startup

WORKDIR /home/$NB_USER
EXPOSE 8888
COPY start-custom.sh /usr/local/bin/
USER $NB_USER
ENTRYPOINT ["tini", "--"]
CMD ["start-custom.sh"]
