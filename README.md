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
│   ├── 6_RemoteDesktop.Dockerfile
│   ├── ∞_CMD.Dockerfile
│   └── ∞_CMD_RemoteDesktop.Dockerfile
│
├── resources                               # the Docker context (files for COPY)
├── ├── common                              # files required by all images
│      ├── clean-layer.sh
│      ├── helpers.zsh
│      ├── jupyterlab-overrides.json
│      ├── landing_page
│      ├── nginx
│      ├── README.md
│      └── start-custom.sh
├── ├── remote-desktop                      # directory containing files only for the remote desktop
|      ├── desktop-files                    # desktop configuration 
|      ├── French                           # files to support i18n of remote desktop
|      ├── qgis-2020.gpg.key
|      └── start-remote-desktop.sh
|      
│
├── scripts                                 # Helper Scripts (NOT automated.)
├── ├── remote-desktop                      # Scripts installing applications on remote desktop
|      ├── firefox.sh
|      ├── fix-permissions.sh
|      ├── qgis.sh
|      ├── r-studio-desktop.sh
|      └── vs-code-desktop.sh
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
    |── RemoteDesktop/
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

### Development Testing Instructions for CI

If making changes to CI that cannot be done on a branch (eg: changes to issue_comment triggers), you can:
* fork the 'kubeflow-containers' repo
* Modify the CI with 
  * REGISTRY: (your own dockerhub repo, eg: "j-smith" (no need for the full url))
  * Change 
  	```
    - uses: azure/docker-login@v1
      with:
        login-server: ${{ env.REGISTRY_NAME }}.azurecr.io
        username: ${{ secrets.REGISTRY_USERNAME }}
        password: ${{ secrets.REGISTRY_PASSWORD }}
  	```
  	to 
  	```
    - uses: docker/login-action@v1
      with:
        username: ${{ secrets.REGISTRY_USERNAME }}
        password: ${{ secrets.REGISTRY_PASSWORD }}
    ```
  * In your forked repo, define secrets for REGISTRY_USERNAME and REGISTRY_PASSWORD with your dockerhub credentials (you should use an API token, not your actual dockerhub password)

## Troubleshooting
If running using a VM and RStudio image was built successfully but is not opening correctly on localhost (error 5000 page), change your CPU allocation in your Linux VM settings to >= 3. You can also use your VM's system monitor to examine if all CPUs are 100% being used as your container is running. If so, increase CPU allocation. 
This was tested on Linux Ubuntu 20.04 virtual machine.
