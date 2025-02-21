# To upgrade, see https://gitlab.com/nvidia/container-images/cuda/-/tree/master/dist

###########################
### Base
###########################

ENV NVARCH x86_64

ENV NVIDIA_REQUIRE_CUDA "cuda>=12.3 brand=tesla,driver>=470,driver<471 brand=unknown,driver>=470,driver<471 brand=nvidia,driver>=470,driver<471 brand=nvidiartx,driver>=470,driver<471 brand=geforce,driver>=470,driver<471 brand=geforcertx,driver>=470,driver<471 brand=quadro,driver>=470,driver<471 brand=quadrortx,driver>=470,driver<471 brand=titan,driver>=470,driver<471 brand=titanrtx,driver>=470,driver<471 brand=tesla,driver>=525,driver<526 brand=unknown,driver>=525,driver<526 brand=nvidia,driver>=525,driver<526 brand=nvidiartx,driver>=525,driver<526 brand=geforce,driver>=525,driver<526 brand=geforcertx,driver>=525,driver<526 brand=quadro,driver>=525,driver<526 brand=quadrortx,driver>=525,driver<526 brand=titan,driver>=525,driver<526 brand=titanrtx,driver>=525,driver<526 brand=tesla,driver>=535,driver<536 brand=unknown,driver>=535,driver<536 brand=nvidia,driver>=535,driver<536 brand=nvidiartx,driver>=535,driver<536 brand=geforce,driver>=535,driver<536 brand=geforcertx,driver>=535,driver<536 brand=quadro,driver>=535,driver<536 brand=quadrortx,driver>=535,driver<536 brand=titan,driver>=535,driver<536 brand=titanrtx,driver>=535,driver<536"
ENV NV_CUDA_CUDART_VERSION 12.3.101-1
ENV NV_CUDA_COMPAT_PACKAGE cuda-compat-12-3

RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg2 curl ca-certificates && \
    curl -fsSLO https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/${NVARCH}/cuda-keyring_1.0-1_all.deb && \
    dpkg -i cuda-keyring_1.0-1_all.deb && \
    apt-get purge --autoremove -y curl \
    && rm -rf /var/lib/apt/lists/*

ENV CUDA_VERSION 12.3.2

# For libraries in the cuda-compat-* package: https://docs.nvidia.com/cuda/eula/index.html#attachment-a
RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-cudart-12-3=${NV_CUDA_CUDART_VERSION} \
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
    

###########################
### Runtime
###########################
# https://gitlab.com/nvidia/container-images/cuda/

ENV NV_CUDA_LIB_VERSION 12.3.2-1

ENV NV_NVTX_VERSION 12.3.101-1
ENV NV_LIBNPP_VERSION 12.2.3.2-1
ENV NV_LIBNPP_PACKAGE libnpp-12-3=${NV_LIBNPP_VERSION}
ENV NV_LIBCUSPARSE_VERSION 12.2.0.103-1

ENV NV_LIBCUBLAS_PACKAGE_NAME libcublas-12-3
ENV NV_LIBCUBLAS_VERSION 12.3.4.1-1
ENV NV_LIBCUBLAS_PACKAGE ${NV_LIBCUBLAS_PACKAGE_NAME}=${NV_LIBCUBLAS_VERSION}

ENV NV_LIBNCCL_PACKAGE_NAME libnccl2
ENV NV_LIBNCCL_PACKAGE_VERSION 2.20.3-1
ENV NCCL_VERSION 2.20.3-1
ENV NV_LIBNCCL_PACKAGE ${NV_LIBNCCL_PACKAGE_NAME}=${NV_LIBNCCL_PACKAGE_VERSION}+cuda12.3

RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-libraries-12-3=${NV_CUDA_LIB_VERSION} \
    ${NV_LIBNPP_PACKAGE} \
    cuda-nvtx-12-3=${NV_NVTX_VERSION} \
    libcusparse-12-3=${NV_LIBCUSPARSE_VERSION} \
    ${NV_LIBCUBLAS_PACKAGE} \
    ${NV_LIBNCCL_PACKAGE} \
    && rm -rf /var/lib/apt/lists/*

# Keep apt from auto upgrading the cublas and nccl packages. See https://gitlab.com/nvidia/container-images/cuda/-/issues/88
RUN apt-mark hold ${NV_LIBCUBLAS_PACKAGE_NAME} ${NV_LIBNCCL_PACKAGE_NAME}

ENV NVIDIA_PRODUCT_NAME="CUDA"

###########################
### CudNN
###########################
# https://gitlab.com/nvidia/container-images/cuda/-/raw/ee72a6fef178d135e8366e5c88e15df39ff83c21/dist/11.8.0/ubuntu1804/runtime/cudnn8/Dockerfile

ENV NV_CUDNN_VERSION 9.0.0.312
ENV NV_CUDNN_PACKAGE_NAME "libcudnn9-cuda-12"

ENV NV_CUDNN_PACKAGE "libcudnn9-cuda-12=${NV_CUDNN_VERSION}-1"

RUN apt-get update && apt-get install -y --no-install-recommends \
    ${NV_CUDNN_PACKAGE} \
    && apt-mark hold ${NV_CUDNN_PACKAGE_NAME} \
    && rm -rf /var/lib/apt/lists/*

# Install Tensorflow
RUN mamba install --quiet --yes \
        tensorflow \
        keras \
        ipykernel \
    && \
    clean-layer.sh && \
    fix-permissions "$CONDA_DIR" && \
    fix-permissions "/home/$NB_USER"
