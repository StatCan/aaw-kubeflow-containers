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
    && echo "${AZCLI_SHA} InstallAzureCLIDeb" | sha256sum -c - \
    && bash InstallAzureCLIDeb 

# Default environment
RUN pip install --quiet \
      'gpustat==0.6.0' \
      'kubernetes==11.0.0' \
      'jupyter-lsp==0.9.1' \
      'jupyter-server-proxy==1.5.0' \
    && \
    conda install --quiet --yes \
      'jupyterlab>=2.2.2' \
    && \
    conda install --quiet --yes \
    -c conda-forge \
      'ipywidgets==7.5.1' \
      'ipympl==0.5.8' \
      'jupyter_contrib_nbextensions==0.5.1' \
      'jupyterlab-git==0.20.0' \
      'xeus-python==0.8.4' \
      'nodejs==12.18.3' \
      'python-language-server==0.31.10 ' \
    && \
    conda install --quiet --yes \
      'pyarrow==0.17.1' \
      'r-dplyr==1.0.2' \
      'r-tidyr==1.1.2' \
      'r-jsonlite==1.7.1' \
      'r-ggplot2==3.3.2' \
      'r-rstan==2.21.2' \
    && \
    conda install --quiet --yes \
     -c plotly \
     'jupyter-dash==0.3.0' \
    && \
    conda clean --all -f -y && \
    jupyter nbextension enable codefolding/main --sys-prefix && \
    jupyter labextension install --no-build \
      '@ijmbarr/jupyterlab_spellchecker@0.1.6' \
      '@jupyter-widgets/jupyterlab-manager@2.0.0'  \
      '@hadim/jupyter-archive@0.7.0' \
      '@krassowski/jupyterlab-lsp@2.0.7' \
      '@lckr/jupyterlab_variableinspector@0.5.1' \
      '@jupyterlab/debugger@0.3.2' \
      '@jupyterlab/github@2.0.0' \
      '@jupyterlab/git@0.20.0' \
      '@jupyterlab/toc@4.0.0' \
      'jupyter-matplotlib@0.7.4' \
      'jupyterlab-execute-time@1.0.0' \
      'jupyterlab-plotly@4.10.0' \
      'jupyterlab-theme-solarized-dark@1.0.2' \
      'jupyterlab-spreadsheet@0.3.2' \
      'nbdime-jupyterlab@2.0.0' \
    && \
    jupyter lab build && \
    jupyter lab clean && \
  npm cache clean --force && \
  rm -rf /home/$NB_USER/.cache/yarn && \
  rm -rf /home/$NB_USER/.node-gyp && \
  fix-permissions $CONDA_DIR && \
  fix-permissions /home/$NB_USER

# Solarized Theme and Cell Execution Time
RUN echo '{ "@jupyterlab/apputils-extension:themes": {"theme": "JupyterLab Solarized Dark"}, "@jupyterlab/notebook-extension:tracker": {"recordTiming": true}}' > /opt/conda/share/jupyter/lab/settings/overrides.json && \
    fix-permissions /home/$NB_USER


# Configure container startup
EXPOSE 8888
USER jovyan
ENTRYPOINT ["tini", "--"]
CMD ["start-custom.sh"]
