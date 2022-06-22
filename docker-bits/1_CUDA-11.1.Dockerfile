# Cuda stuff for v11.1

## https://gitlab.com/nvidia/container-images/cuda/-/raw/master/dist/11.1/ubuntu18.04-x86_64/base/Dockerfile

###########################
### Base
###########################
# https://gitlab.com/nvidia/container-images/cuda/-/raw/master/dist/11.1/ubuntu18.04-x86_64/base/Dockerfile

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
ENV NVIDIA_REQUIRE_CUDA "cuda>=11.7 brand=tesla,driver>=418,driver<419 brand=tesla,driver>=440,driver<441 brand=tesla,driver>=450,driver<451"

# ###########################
# ### Devel
# ###########################
# # https://gitlab.com/nvidia/container-images/cuda/-/raw/master/dist/11.1/ubuntu18.04-x86_64/devel/Dockerfile
#
# $(curl -s https://gitlab.com/nvidia/container-images/cuda/-/raw/master/dist/11.1/ubuntu18.04-x86_64/devel/Dockerfile)

###########################
### Runtime
###########################
# https://gitlab.com/nvidia/container-images/cuda/-/raw/master/dist/11.1/ubuntu18.04-x86_64/runtime/Dockerfile

ENV NCCL_VERSION 2.12.12

RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-libraries-11-7=11.7.0-1 \
    libnpp-11-7=11.7.3.21-1 \
    cuda-nvtx-11-7=11.7.50-1 \
    libcublas-11-7=11.10.1.25-1 \
    libnccl2=$NCCL_VERSION-1+cuda11.7 \
    && apt-mark hold libnccl2 \
    && rm -rf /var/lib/apt/lists/*

###########################
### CudNN
###########################
# https://gitlab.com/nvidia/container-images/cuda/-/raw/master/dist/11.1/ubuntu18.04-x86_64/runtime/cudnn8/Dockerfile

ENV CUDNN_VERSION 8.4.1.50

LABEL com.nvidia.cudnn.version="${CUDNN_VERSION}"

RUN apt-get update && apt-get install -y --no-install-recommends \
    libcudnn8=$CUDNN_VERSION-1+cuda11.6 \
    && apt-mark hold libcudnn8 && \
    rm -rf /var/lib/apt/lists/*
