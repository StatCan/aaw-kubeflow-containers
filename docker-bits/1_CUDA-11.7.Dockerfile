# Cuda stuff for v11.7

## https://gitlab.com/nvidia/container-images/cuda/-/blob/92d100e5ad724656d3b7315db8ce268ab7cb9d91/dist/11.7.0/ubuntu1804/base/Dockerfile

###########################
### Base
###########################
# https://gitlab.com/nvidia/container-images/cuda/-/blob/92d100e5ad724656d3b7315db8ce268ab7cb9d91/dist/11.7.0/ubuntu1804/base/Dockerfile

RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg2 curl ca-certificates && \
    apt-get purge --autoremove -y curl \
    && rm -rf /var/lib/apt/lists/*

ENV CUDA_VERSION 11.7.0

# For libraries in the cuda-compat-* package: https://docs.nvidia.com/cuda/eula/index.html#attachment-a
RUN apt-get update && apt-get install -y wget && \
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-keyring_1.0-1_all.deb && \
    dpkg -i cuda-keyring_1.0-1_all.deb && \
    apt-get update && apt-get install -y --no-install-recommends \
    cuda-cudart-11-7=11.7.60-1 \
    cuda-compat-11-7 \
    && ln -s cuda-11.7 /usr/local/cuda && \
    rm -rf /var/lib/apt/lists/*

# Required for nvidia-docker v1
RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=11.7 brand=tesla,driver>=450,driver<451 brand=tesla,driver>=470,driver<471 brand=unknown,driver>=470,driver<471 brand=nvidia,driver>=470,driver<471 brand=nvidiartx,driver>=470,driver<471 brand=quadrortx,driver>=470,driver<471 brand=unknown,driver>=510,driver<511 brand=nvidia,driver>=510,driver<511 brand=nvidiartx,driver>=510,driver<511 brand=quadrortx,driver>=510,driver<511"

# ###########################
# ### Devel
# ###########################
# # https://gitlab.com/nvidia/container-images/cuda/-/blob/92d100e5ad724656d3b7315db8ce268ab7cb9d91/dist/11.7.0/ubuntu1804/devel/Dockerfile
#
# $(curl -s https://gitlab.com/nvidia/container-images/cuda/-/blob/92d100e5ad724656d3b7315db8ce268ab7cb9d91/dist/11.7.0/ubuntu1804/devel/Dockerfile)

###########################
### Runtime
###########################
# https://gitlab.com/nvidia/container-images/cuda/-/blob/92d100e5ad724656d3b7315db8ce268ab7cb9d91/dist/11.7.0/ubuntu1804/runtime/Dockerfile

ENV NCCL_VERSION 2.12.12

RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-libraries-11-7=11.7.0-1 \
    libnpp-11-7=11.7.3.21-1 \
    cuda-nvtx-11-7=11.7.50-1 \
    libcusparse-11-7=11.7.3.50-1 \
    libcublas-11-7=11.10.1.25-1 \
    libnccl2=$NCCL_VERSION-1+cuda11.7 \
    && apt-mark hold libnccl2 \
    && rm -rf /var/lib/apt/lists/*