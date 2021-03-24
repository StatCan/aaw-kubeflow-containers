# installs vscode server, python & conda packages and jupyter lab extensions.
# Using JupyterLab 3.0 from docker-stacks base image. This new version is not yet supported by some extensions so they have been removed until new compatible versions are available.

# JupyterLab 3.0 introduced i18n and i10n which now allows us to have a fully official languages compliant image.

# Currently installing jupyterlab-git extensions from specific commit in repo master branch. This is temporary until a new release is made available on PIP.
# Use official package jupyterlab-language-pack-fr-FR when released by Jupyterlab instead of the StatCan/jupyterlab-language-pack-fr_FR repo.

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
ENV XDG_DATA_HOME=/etc/share
ENV SERVICE_URL=https://extensions.coder.com/api
COPY vscode-overrides.json $XDG_DATA_HOME/code-server/User/settings.json
ARG SHA256py=a4191fefc0e027fbafcd87134ac89a8b1afef4fd8b9dc35f14d6ee7bdf186348

RUN VS_PYTHON_VERSION="2020.5.86806" && \
    wget --quiet --no-check-certificate https://github.com/microsoft/vscode-python/releases/download/$VS_PYTHON_VERSION/ms-python-release.vsix && \
    echo "${SHA256py} ms-python-release.vsix" | sha256sum -c - && \
    code-server --install-extension ms-python-release.vsix && \
    rm ms-python-release.vsix && \
    code-server --install-extension ikuyadeu.r@1.6.2 && \
    code-server --install-extension MS-CEINTL.vscode-language-pack-fr@1.51.2 && \
    fix-permissions $XDG_DATA_HOME

# Default environment
RUN pip install --quiet \
      'jupyter-lsp==1.1.4' \
      'jupyter-server-proxy==1.6.0' \
      'kubeflow-kale==0.6.1' \
      'jupyterlab_execute_time==2.0.1' \
      'git+https://github.com/betatim/vscode-binder' \
    && \
    conda install --quiet --yes \
    -c conda-forge \
      'ipywidgets==7.6.3' \
      'ipympl==0.6.3' \
      'jupyter_contrib_nbextensions==0.5.1' \
      'nb_conda_kernels==2.3.1' \
      'nodejs==14.14.0' \
      'python-language-server==0.36.2' \
      'jupyterlab-translate==0.1.1' \
    && \
    conda install --quiet --yes \
      -c plotly \
      'jupyter-dash==0.4.0' \
    && \
    pip install \
      'git+http://github.com/jupyterlab/jupyterlab-git.git@0b1a0f274e85572f4de3b7347a20ac9830bbced1' \
      'git+http://github.com/JessicaBarh/jupyterlab-lsp.git#egg=jupyterlab_lsp&subdirectory=python_packages/jupyterlab_lsp' \
      'git+https://github.com/StatCan/jupyterlab-language-pack-fr_FR.git' \
    && \
    conda clean --all -f -y && \
    jupyter serverextension enable --py jupyter_server_proxy && \
    jupyter nbextension enable codefolding/main --sys-prefix && \
    jupyter labextension install --no-build \
      '@jupyterlab/translation-extension@3.0.4' \
      '@jupyterlab/server-proxy@2.1.2' \
      '@hadim/jupyter-archive@3.0.0' \
      'jupyterlab-plotly@4.14.3' \
      'nbdime-jupyterlab' \
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
