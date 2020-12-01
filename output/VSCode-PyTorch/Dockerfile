
###############################
###  .tmp/PyTorch.Dockerfile
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
###  docker-bits/1_CUDA-11.0.Dockerfile
###############################

# Cuda stuff for v11.0

## https://gitlab.com/nvidia/container-images/cuda/-/raw/master/dist/11.0/ubuntu18.04-x86_64/base/Dockerfile

###########################
### Base
###########################
# https://gitlab.com/nvidia/container-images/cuda/-/raw/master/dist/11.0/ubuntu18.04-x86_64/base/Dockerfile

RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg2 curl ca-certificates && \
    curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub | apt-key add - && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
    echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list && \
    apt-get purge --autoremove -y curl \
    && rm -rf /var/lib/apt/lists/*

ENV CUDA_VERSION 11.0.3

# For libraries in the cuda-compat-* package: https://docs.nvidia.com/cuda/eula/index.html#attachment-a
RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-cudart-11-0=11.0.221-1 \
    cuda-compat-11-0 \
    && ln -s cuda-11.0 /usr/local/cuda && \
    rm -rf /var/lib/apt/lists/*

# Required for nvidia-docker v1
RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=11.0 brand=tesla,driver>=418,driver<419 brand=tesla,driver>=440,driver<441 brand=tesla,driver>=450,driver<451"

# ###########################
# ### Devel
# ###########################
# # https://gitlab.com/nvidia/container-images/cuda/-/raw/master/dist/11.0/ubuntu18.04-x86_64/devel/Dockerfile
#
# $(curl -s https://gitlab.com/nvidia/container-images/cuda/-/raw/master/dist/11.0/ubuntu18.04-x86_64/devel/Dockerfile)

###########################
### Runtime
###########################
# https://gitlab.com/nvidia/container-images/cuda/-/raw/master/dist/11.0/ubuntu18.04-x86_64/runtime/Dockerfile

ENV NCCL_VERSION 2.7.8

RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-libraries-11-0=11.0.3-1 \
    libnpp-11-0=11.1.0.245-1 \
    cuda-nvtx-11-0=11.0.167-1 \
    libcublas-11-0=11.2.0.252-1 \
    libnccl2=$NCCL_VERSION-1+cuda11.0 \
    && apt-mark hold libnccl2 \
    && rm -rf /var/lib/apt/lists/*

###########################
### CudNN
###########################
# https://gitlab.com/nvidia/container-images/cuda/-/raw/master/dist/11.0/ubuntu18.04-x86_64/runtime/cudnn8/Dockerfile

ENV CUDNN_VERSION 8.0.4.30

LABEL com.nvidia.cudnn.version="${CUDNN_VERSION}"

RUN apt-get update && apt-get install -y --no-install-recommends \
    libcudnn8=$CUDNN_VERSION-1+cuda11.0 \
    && apt-mark hold libcudnn8 && \
    rm -rf /var/lib/apt/lists/*


###############################
###  docker-bits/2_PyTorch.Dockerfile
###############################

# Install PyTorch
RUN conda config --set channel_priority false && \
    conda create -n torch python=3.7 && \
    conda install -n torch --quiet --yes \
      'pytorch-gpu' \
      'torchvision' \
      'ipykernel' \
    && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

###############################
###  docker-bits/3_Kubeflow.Dockerfile
###############################

RUN pip --no-cache-dir install --quiet \
      'kfp==1.0.0' \
      'kfp-server-api==1.0.0' \
      'kfp-tekton==0.3.0' \
      'kubeflow-fairing==1.0.1' \
      'ml-metadata==0.24.0' \
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
COPY helpers.zsh /tmp/helpers.zsh

###############################
###  docker-bits/5_DB-Drivers.Dockerfile
###############################

# ODBC drivers
RUN apt-get update && \
    apt-get install -y alien unixodbc unixodbc-dev && \
    pip install --no-cache-dir --quiet 'pyodbc==4.0.30' && \
    rm -rf /var/lib/apt/lists/*

# Add PGWeb too
ENV PGWEB_VERSION 0.11.7
ARG PGWEB_SHA256=87afd2aa1a087d0e61fa9624178cdf5ea663dec545ae0b6d3c0351f9deacd681
RUN \
  cd /tmp && \
  wget -q https://github.com/sosedoff/pgweb/releases/download/v$PGWEB_VERSION/pgweb_linux_amd64.zip && \
  echo "$PGWEB_SHA256  pgweb_linux_amd64.zip" | sha256sum -c - && \
  unzip pgweb_linux_amd64.zip -d /usr/bin && \
  mv /usr/bin/pgweb_linux_amd64 /usr/bin/pgweb && \
  rm -f pgweb_linux_amd64.zip

###############################
###  docker-bits/6_VSCode.Dockerfile
###############################

USER ${NB_USER}

ARG CODESERVER_URL="https://github.com/cdr/code-server/releases/download/1.1119-vsc1.33.1/code-server1.1119-vsc1.33.1-linux-x64.tar.gz"
ARG CODESERVER="code-server1.1119-vsc1.33.1-linux-x64"
ARG CODESERVER_SHA=dcd024301226eb493db2d06454b5d57a3499fbbc17fd816a68a2333ee3482685

ARG VSCODE_VERSION=3.6.2
ARG VSCODE_SHA=71edb5776a7f965bf720c9814ab2e762fbaa0ddad4d9f4f85848c3912df1b67c
ARG VSCODE_URL=https://github.com/cdr/code-server/releases/download/v${VSCODE_VERSION}/code-server_${VSCODE_VERSION}_amd64.deb

USER root
RUN wget -q "${VSCODE_URL}" -O ./vscode.deb \
    && echo "${VSCODE_SHA}  ./vscode.deb" | sha256sum -c - \
    && apt-get update \
    && apt-get install -y nginx \
    && apt-get install -y ./vscode.deb \
    && rm ./vscode.deb \
    && rm -f /etc/apt/sources.list.d/vscode.list \
    && echo "Install codeserver" \
    && wget -q ${CODESERVER_URL} \
    && echo "${CODESERVER_SHA}  ${CODESERVER}.tar.gz" | sha256sum -c - \
    && tar xvf ${CODESERVER}.tar.gz \
    && mv ${CODESERVER}/code-server /usr/local/bin/ \
    && rm -rf code-server*

USER $NB_USER
RUN pip install jupyter-server-proxy \
    && pip install git+https://github.com/blairdrummond/vscode-binder \
    && pip install git+https://github.com/illumidesk/jupyter-pluto-proxy \
    && pip install git+https://github.com/illumidesk/jupyter-pgweb-proxy.git \
    && conda install --yes nb_conda_kernels \
    && ( julia -e 'import Pkg; Pkg.update(); Pkg.add("Pluto")' || true; ) \
    && chmod -R go+rx "${CONDA_DIR}/share/jupyter" \
    && rm -rf "${HOME}/.local" \
    && fix-permissions "${CONDA_DIR}/share/jupyter" \
    && ([ ! -d "${JULIA_PKGDIR}" ] || fix-permissions "${JULIA_PKGDIR}") \
    && jupyter serverextension enable --py jupyter_server_proxy \
    && jupyter labextension install @jupyterlab/server-proxy \
    && jupyter lab build \
    && conda clean --all -f -y \
    && rm -rf /home/$NB_USER/.cache/yarn \
    && rm -rf /home/$NB_USER/.node-gyp \
    && fix-permissions $CONDA_DIR \
    && fix-permissions /home/$NB_USER \
    && echo "VSCode installed."

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
