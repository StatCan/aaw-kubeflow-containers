# Containers for Kubeflow

Containers to be used with Kubeflow for Data Science.

## Introduction

Our Container images are based on the community driven [jupyter/docker-stacks](https://github.com/jupyter/docker-stacks). This enables us to focus only on the additional toolsets that we require to enable our data scientists.

## Structure


```
.
├── Makefile                                # Cats the docker-bits together
│
├── docker-bits                             # The docker snippets. Numbering indicates the DAG.
│   ├── 0_CPU.Dockerfile
│   ├── 1_CUDA-11.0.Dockerfile
│   ├── 1_CUDA-11.1.Dockerfile
│   ├── 2_PyTorch.Dockerfile
│   ├── 2_Tensorflow.Dockerfile
│   ├── 3_Kubeflow.Dockerfile
│   ├── 4_CLI.Dockerfile
│   ├── 5_DB-Drivers.Dockerfile
│   ├── 6_JupyterLab.Dockerfile
│   ├── 6_RStudio.Dockerfile
│   ├── 6_JupyterLab-OL-compliant.Dockerfile
│   └── ∞_CMD.Dockerfile
│
├── resources                               # the Docker context (files for COPY)
│   ├── clean-layer.sh
│   ├── helpers.zsh
│   ├── jupyterlab-overrides.json
│   ├── landing_page
│   ├── nginx
│   ├── README.md
│   └── start-custom.sh
│
├── scripts                                 # Helper Scripts (NOT automated.)
│   ├── CHECKSUMS
│   ├── checksums.sh
│   ├── get-nvidia-stuff.sh
│   ├── start-custom-OL-compliant.sh
│   └── README.md
│
└── output                                  # Staging area for a `docker build .`
    ├── JupyterLab-CPU/
    ├── JupyterLab-PyTorch/
    ├── JupyterLab-Tensorflow/
    |── RStudio/
    ├── JupyterLab-CPU-OL-compliant/        # These images use JupyterLab 3.0 and contain only OL-compliant extensions
    ├── JupyterLab-PyTorch-OL-compliant/
    └── JupyterLab-Tensorflow-OL-compliant/
```
## Deployment Testing Instructions

The output folder contains Dockerfiles for each Notebook made from a combination of different [docker-bits](/docker-bits). They are created on `make all`.

Make your changes to the correct [docker-bits](/docker-bits) file and not the files in `output/` folder otherwise it will get overwritten. Same goes for the shell scripts and json files - they should be modified from the [resources](/resources) folder. 

Now build and run your image:

```bash
# from kubeflow-containers directory
make all
cd output/<notebook-name>
docker build . -t tagName:version
docker run -p 8888:8888 tagName:version
```
Now open in http://localhost:8888/.

## Troubleshooting
If running using a VM and RStudio image was built successfully but is not opening correctly on localhost (error 5000 page), change your CPU allocation in your Linux VM settings to >= 3. You can also use your VM's system monitor to examine if all CPUs are 100% being used as your container is running. If so, increase CPU allocation. 
This was tested on Linux Ubuntu 20.04 virtual machine.
