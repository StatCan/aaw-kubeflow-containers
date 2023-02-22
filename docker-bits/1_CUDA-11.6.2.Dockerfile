# Cuda stuff for v11.6.2

## https://gitlab.com/nvidia/container-images/cuda/-/raw/master/dist/11.6.2/ubuntu1804/base/Dockerfile

###########################
### Base
###########################
# https://gitlab.com/nvidia/container-images/cuda/-/raw/master/dist/11.6.2/ubuntu1804/base/Dockerfile



ENV NVARCH x86_64

ENV NVIDIA_REQUIRE_CUDA "cuda>=11.6 brand=tesla,driver>=418,driver<419 brand=tesla,driver>=450,driver<451 brand=tesla,driver>=470,driver<471 brand=unknown,driver>=470,driver<471 brand=nvidia,driver>=470,driver<471 brand=nvidiartx,driver>=470,driver<471 brand=geforce,driver>=470,driver<471 brand=geforcertx,driver>=470,driver<471 brand=quadro,driver>=470,driver<471 brand=quadrortx,driver>=470,driver<471 brand=titan,driver>=470,driver<471 brand=titanrtx,driver>=470,driver<471"
ENV NV_CUDA_CUDART_VERSION 11.6.55-1
ENV NV_CUDA_COMPAT_PACKAGE cuda-compat-11-6


ARG TARGETARCH


RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg2 curl ca-certificates && \
    curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/${NVARCH}/3bf863cc.pub | apt-key add - && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/${NVARCH} /" > /etc/apt/sources.list.d/cuda.list && \
    apt-get purge --autoremove -y curl \
    && rm -rf /var/lib/apt/lists/*

ENV CUDA_VERSION 11.6.2

# For libraries in the cuda-compat-* package: https://docs.nvidia.com/cuda/eula/index.html#attachment-a
RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-cudart-11-6=${NV_CUDA_CUDART_VERSION} \
    ${NV_CUDA_COMPAT_PACKAGE} \
    && rm -rf /var/lib/apt/lists/*

# Required for nvidia-docker v1
RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf \
    && echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64


# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility

# ###########################
# ### Devel
# ###########################
# # https://gitlab.com/nvidia/container-images/cuda/-/raw/master/dist/11.6.2/ubuntu1804/devel/Dockerfile
#
# $(curl -s https://gitlab.com/nvidia/container-images/cuda/-/raw/master/dist/11.6.2/ubuntu1804/devel/Dockerfile)

###########################
### Runtime
###########################
# https://gitlab.com/nvidia/container-images/cuda/-/raw/master/dist/11.6.2/ubuntu1804/runtime/Dockerfile


ENV NV_CUDA_LIB_VERSION 11.6.2-1


ENV NV_NVTX_VERSION 11.6.124-1
ENV NV_LIBNPP_VERSION 11.6.3.124-1
ENV NV_LIBNPP_PACKAGE libnpp-11-6=${NV_LIBNPP_VERSION}
ENV NV_LIBCUSPARSE_VERSION 11.7.2.124-1

ENV NV_LIBCUBLAS_PACKAGE_NAME libcublas-11-6
ENV NV_LIBCUBLAS_VERSION 11.9.2.110-1
ENV NV_LIBCUBLAS_PACKAGE ${NV_LIBCUBLAS_PACKAGE_NAME}=${NV_LIBCUBLAS_VERSION}

ENV NV_LIBNCCL_PACKAGE_NAME libnccl2
ENV NV_LIBNCCL_PACKAGE_VERSION 2.12.10-1
ENV NCCL_VERSION 2.12.10-1
ENV NV_LIBNCCL_PACKAGE ${NV_LIBNCCL_PACKAGE_NAME}=${NV_LIBNCCL_PACKAGE_VERSION}+cuda11.6


ENV NV_NVTX_VERSION 11.6.124-1
ENV NV_LIBNPP_VERSION 11.6.3.124-1
ENV NV_LIBNPP_PACKAGE libnpp-11-6=${NV_LIBNPP_VERSION}
ENV NV_LIBCUSPARSE_VERSION 11.7.2.124-1

ENV NV_LIBCUBLAS_PACKAGE_NAME libcublas-11-6
ENV NV_LIBCUBLAS_VERSION 11.9.2.110-1
ENV NV_LIBCUBLAS_PACKAGE ${NV_LIBCUBLAS_PACKAGE_NAME}=${NV_LIBCUBLAS_VERSION}


ARG TARGETARCH

RUN wget -q -O /tmp/liburcu6_0.11.1-2_amd64.deb http://mirrors.kernel.org/ubuntu/pool/main/libu/liburcu/liburcu6_0.11.1-2_amd64.deb \
    && dpkg -i /tmp/liburcu6_0.11.1-2_amd64.deb \
    && rm /tmp/liburcu6_0.11.1-2_amd64.deb

RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-libraries-11-6=${NV_CUDA_LIB_VERSION} \
    ${NV_LIBNPP_PACKAGE} \
    cuda-nvtx-11-6=${NV_NVTX_VERSION} \
    libcusparse-11-6=${NV_LIBCUSPARSE_VERSION} \
    ${NV_LIBCUBLAS_PACKAGE} \
    ${NV_LIBNCCL_PACKAGE} \
    && rm -rf /var/lib/apt/lists/*

# Add entrypoint items
ENV NVIDIA_PRODUCT_NAME="CUDA"

###########################
### CudNN
###########################
# https://gitlab.com/nvidia/container-images/cuda/-/raw/master/dist/11.6.2/ubuntu1804/runtime/cudnn8/Dockerfile



ENV NV_CUDNN_VERSION 8.4.0.27
ENV NV_CUDNN_PACKAGE_NAME "libcudnn8"

ENV NV_CUDNN_PACKAGE "libcudnn8=$NV_CUDNN_VERSION-1+cuda11.6"


ENV NV_CUDNN_VERSION 8.4.0.27
ENV NV_CUDNN_PACKAGE_NAME "libcudnn8"

ENV NV_CUDNN_PACKAGE "libcudnn8=$NV_CUDNN_VERSION-1+cuda11.6"


ARG TARGETARCH

LABEL com.nvidia.cudnn.version="${NV_CUDNN_VERSION}"

RUN apt-get update && apt-get install -y --no-install-recommends \
    ${NV_CUDNN_PACKAGE} \
    && apt-mark hold ${NV_CUDNN_PACKAGE_NAME} \
    && rm -rf /var/lib/apt/lists/*

