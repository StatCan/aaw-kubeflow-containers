# Containers for Kubeflow

Container images to be used with kubeflow on the AAW platform for Data Science & other workloads.

## Introduction

Our Container images are based on the community driven [jupyter/docker-stacks](https://github.com/jupyter/docker-stacks). We chose those images because they are continuously updated and install the most common utilities. This enables us to focus only on the additional toolsets that we require to enable our data scientists. These customized images are maintained by the AAW team and are the default images available on the kubeflow UI. This is different from the [aaw-contrib-containers](https://github.com/StatCan/aaw-contrib-containers) as those images are built by AAW user-base. These are often created when a user's workload is more specific and our generic images are not suitable for them. Those images can be used via the `custom-image` feature in kubeflow and do not populate the default images drop-down. Additionally, the AAW team is not responsible for maintaining those images.

## List of maintained images in this github repository
| Image Name            | Notes                                                                                                                                            | Extra Installations  |
|-----------------------|--------------------------------------------------------------------------------------------------------------------------------------------------|----------------------|
| jupyterlab-cpu        | The base experience. A jupyterlab notebook with various installations.                                                                           | VsCode, R, Julia     |
| jupyterlab-pytorch    | For users looking to leverage a GPU machine. Comes installed with pytorch                                                                        | pytorch, torchvision |
| jupyterlab-tensorflow | For users looking to leverage a GPU machine. Comes installed with tensorflow                                                                     | tensorflow-gpu       |
| remote-desktop        | For users looking to have a desktop-like experience.                                                                                             | Open M++, QGIS       |
| rstudio               | For users looking to have a rstudio tuned experience.                                                                                            |                      |
| sas                   | Similar to our jupyterlab-cpu image, except with SAS. This is only available  to Statistics Canada employees as that is what our license allows. |                      |

## Usage

### Generating Dockerfiles

Use `make generate-dockerfiles` to generate all `Dockerfile`s.  These will be written to `./output/imagename`, along with any required files for the build context

### Building and Tagging Docker Images

Use `make build/IMAGENAME` to build an **already generated** (see above) `Dockerfile`.  This by default generates images with:
* `repo=k8scc01covidacr.azurecr.io`
* `tag=BRANCH_NAME`
For example: `k8scc01covidacr.azurecr.io/IMAGENAME:BRANCH_NAME`.  

`make build` also accepts arguments for REPO and TAG to override these behaviours.  For example, `make build/jupyterlab-cpu REPO=myrepo TAG=notLatest`.

`make post-build/IMAGENAME` is meant for anything that is commonly done after building an image, but currently only adds common tags.  It adds tags of SHA, SHORT_SHA, and BRANCH_NAME to the given image, and accepts a `SOURCE_FULL_IMAGE_NAME` argument if you're trying to tag an existing image that has a non-typical name.  For example:
* `make post-build/IMAGENAME` will apply SHA, SHORT_SHA, and BRANCH_NAME tags to `k8scc01covidacr.azurecr.io/IMAGENAME:BRANCH_NAME` (eg: using the default REPO and TAG names)
* `make post-build/IMAGENAME SOURCE_FULL_IMAGE_NAME=oldRepo/oldImage:oldTag REPO=newRepo` will make the following new aliases for `oldRepo/oldImage:oldTag REPO=newRepo`:
  * `newRepo/IMAGENAME:SHA`
  * `newRepo/IMAGENAME:SHORT_SHA`
  * `newRepo/IMAGENAME:BRANCH_NAME`

### Pulling and Pushing Docker Images

`make pull/IMAGENAME` and `make push/IMAGENAME` work similarly to `make build/IMAGENAME`.  `REPO` and `TAG` arguments are available to override their default values.

**Note:** To use `make pull` or `make push`, you must first log in to ACR (`az acr login -n k8scc01covidacr`)
**Note:** `make push` by default does `docker push --all-tags` in order to push the SHA, SHORT_SHA, etc., tags.  

### Testing images

#### Running and Connecting to Images Locally/Interactively

To test an image interactively, use `make dev/IMAGENAME`.  This `docker run`'s a built image, automatically forwarding ports to your local machine and providing a link to connect to.

#### Automated Testing

Automated tests are included for the generated Docker images using `pytest`.  This testing suite is modified from the [docker-stacks](https://github.com/jupyter/docker-stacks) test suite.  Image testing is invoked through `make test/IMAGENAME`  (with optional `REPO` and `TAG` arguments like `make build`).

Testing of a given image consists of general and image-specific tests:

```
└── tests
    ├── general                             # General tests applied to all images
    │   └── some_general_test.py
    ├── jupyterlab-cpu                      # Test applied to a specific image
    │   └── some_jupyterlab-cpu-specific_test.py
    └── jupyterlab-tensorflow
```

Where `tests/general` tests are applied to all images, and `tests/IMAGENAME` are applied only to a specific image.  Pytest will start the image locally and then run the provided tests to determine if Jupyterlab is running, python packages are working properly, etc.  Tests are formatted using typical pytest formats (python files with `def test_SOMETHING()` functions).  `conftest.py` defines some standard scaffolding for image management, etc.

## General Development Workflow

### 💻 Running AAW Locally (simple instructions)

1. Clone the repository with `git clone https://github.com/StatCan/aaw-kubeflow-containers`.
2. Build your image using `make build/IMAGENAME`, e.g. run `make build/jupyterlab-tensorflow`.
3. Run `make install-python-dev-venv` to build a development Python virtual environment.
4. Test your image using automated tests through `make test/IMAGENAME`, e.g. run `make test/jupyterlab-tensorflow`.
5. Find your images (required for the next step) with `docker images`. You should see a table printed in the console with your images. For example you may see:

```
username@hostname:~$ docker images
REPOSITORY                                         TAG            IMAGE ID       CREATED          SIZE
k8scc01covidacr.azurecr.io/jupyterlab-tensorflow   master         13f8dc0e4f7a   26 minutes ago   14.6GB
k8scc01covidacr.azurecr.io/jupyterlab-pytorch      master         2b9acb795079   19 hours ago     15.5GB
jupyter/datascience-notebook                       9ed3b8de5de1   9a0c8d86de1a   5 weeks ago      4.25GB
```

7. Run your image with `docker run -p 8888:8888 REPO/IMAGENAME:TAG`, e.g. `docker run -p 8888:8888 k8scc01covidacr.azurecr.io/jupyterlab-tensorflow:master`.
8. Open [http://localhost:8888](http://localhost:8888) or `<ip-address-of-server>:8888`.

### Modifying Dockerfiles (local testing)

* Clone the repo
* (optional) `make pull/IMAGENAME TAG=SOMEEXISTINGTAG` to pull an existing version of the image you are working on (this could be useful as a build cache to reduce development time below)
* Change an image via the [docker-bits](/docker-bits) that are used to create it, **not the files in the output/ folder**.  Same goes for the shell scripts and json files - they should be modified from the [resources](/resources) folder. 
  * For quick-iteration debugging you can directly edit the `./output` files, but make sure you commit any changes you want to keep back to the `./docker-bits`
* After making your changes, generate new Dockerfiles through `make generate-dockerfiles`
* Build your edited image using `make build/IMAGENAME` (or, if you pulled a version of it above, you can use `make build/IMAGENAME DARGS="--cache-from SOMEOLDREPO/SOMEOLDIMAGE:SOMETAG"`, which will use layers from the pulled image as cached layers if possible, speeding up your build)
* Test your image:
  * using automated tests through `make test/IMAGENAME`
  * manually by `docker run -it -p 8888:8888 REPO/IMAGENAME:TAG`, then opening it in [http://localhost:8888](http://localhost:8888)

### Modifying Dockerfiles (on-platform testing)

GitHub Actions CI is enabled to do building, scanning, automated testing, and (optionally) pushing of our images to ACR.  Build, test, and scan CI triggers on:
* any push to master
* any push to an open PR
This allows for easy scanning and automated testing for images.

GitHub Actions CI also enables pushing built images to our ACRs, making them accessible from the platform. 

Pushes to the `master` branch will push to the k8scc01covidacr.azurecr.io ACR and these are accessible from both the dev and prod cluster.
You can access these images using any of the following:
* k8scc01covidacr.azurecr.io/IMAGENAME:SHA
* k8scc01covidacr.azurecr.io/IMAGENAME:SHORT_SHA
* k8scc01covidacr.azurecr.io/IMAGENAME:latest
* k8scc01covidacr.azurecr.io/IMAGENAME:v1


Any push to an open PR **that also has the `auto-deploy` label on the PR**
This allows developers to opt-in to on-platform testing. For example, when you need to build in github and test on platform (or want someone else to be able to pull your image):
* open a PR and add the `auto-deploy` label
* push to your PR and watch the GitHub Action CI
* access your image in Kubeflow DEV via a custom image from any of:
  * k8scc01covidacrdev.azurecr.io/IMAGENAME:SHA
  * k8scc01covidacrdev.azurecr.io/IMAGENAME:SHORT_SHA
  * k8scc01covidacrdev.azurecr.io/IMAGENAME:dev (for convenience in testing)

Images pushed to the dev acr are only available to the DEV cluster, attempting to use them in prod will fail.

### docker-bits, the Makefile and You
The files in the `docker-bits` directory each make up a part of the final dockerfile and are combined depending on what type of dockerfile is being generated. You can see which "docker-bits" go into the dockerfile under their respective 'target'.

 For example for the `remote-desktop` image you can see in the makefile the following
```
mkdir -p $(OUT)/$@
	echo "REMOTE DESKTOP"
	cp -r scripts/remote-desktop $(OUT)/$@
	cp -r resources/common/. $(OUT)/$@
	cp -r resources/remote-desktop/. $(OUT)/$@

  ## HERE IS WHAT GOES INTO THE DOCKERFILE
	$(CAT) \
		$(SRC)/0_Rocker.Dockerfile \
		$(SRC)/3_Kubeflow.Dockerfile \
		$(SRC)/4_CLI.Dockerfile \
		$(SRC)/6_remote-desktop.Dockerfile \
		$(SRC)/7_remove_vulnerabilities.Dockerfile \
		$(SRC)/∞_CMD_remote-desktop.Dockerfile \
	>   $(OUT)/$@/Dockerfile
```
The first portion sets up and copies locally what scripts or utilities the final `Dockerfile` will need. The final `Dockerfile` is then generated using `0_Rocker.Dockerfile` up to `∞_CMD_remote-desktop.Dockerfile` as you can see above.

The `Makefile` sits in the root level of this directory and orchestrates the final dockerfile using the `make generate-dockerfiles` command. The segments of `Dockerfile`s are assembled and you can view which `docker-bit` it came from from the `Dockerfile` comments.  All output images should meet the following criteria:

* be generated by calling `make generate-dockerfiles`
* have outputs written to `output/imagename`, where `imagename` is a **valid Docker image name** (eg: all lowercase, no special characters)

Always, before pushing to a branch ensure you run `make generate-dockerfiles` as if the `output` dockerfiles are out of sync from the `make generate-dockerfiles` the CI will fail.  

### Adding new software

The developer has to make changes to the relevant `docker-bit` and then run the `make generate-dockerfiles`. *NOTE:* We do not allow for adding of software willy nilly, as our image sizes are already quite big (8Gb plus) and increasing that size would negatively impact the time it takes up for a workspace server to come up (as well as first time image pulls to a node). In such cases it may be more relevant to make an image under [aaw-contrib-containers](https://github.com/StatCan/aaw-contrib-containers) as mentioned earlier.

### Adding new Images

To add new images, edit the makefile such that it generates the `./output/imagename` directory.  You can usually follow the existing recipes (or even add an extra piece to them), or you can add a whole new `make` target (but make sure to add your new target to `make generate-dockerfiles` as well).

### Modifying and Testing CI

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

**Note:** Since pushing comes right at the end of the CI, in many cases you don't need to have a valid registry to test the CI on a fork.  It will fail on the push step, but all other steps will clearly work and you can know it should safely merge back into the main repo.

## Other Development Notes

### The `latest` and `v1` tags for the master branch

These are intended to be `long-lived` in that they will not change. Subsequent pushes will clobber the previous `jupyterlab-cpu:latest` image. Previously when we built and pushed to master with updates to an image, we would need to go and change the spawner to use that new image. This will allow us to have them reference `jupyterlab-cpu:latest` and remove us from needing to update it. Additionally, upon changing the `ImagePullPolicy` to `Always` we could do restarts of workloads and then guarantee that users are on the 'latest' image.

The `v1` tag is intended for when we encounter a breaking change but still want to support the features of that current image. We would then branch off and modify the CI as well as increment the tag. 

---
### Set User File Permissions after Every `pip`/`conda` Install or Edit of User's Home Files

The Dockerfiles in this repo are intended to construct compute environments for a non-root user **jovyan** to ensure the end user has the least privileges required for their task, but installation of some of the software needed by the user must be done as the **root** user.  This means that installation of anything that should be user editable (eg: `pip` and `conda` installs, additional files in `/home/$NB_USER`, etc.) will by default be owned by **root** and not modifiable by **jovyan**. **Therefore we must change the permissions of these files to allow the user specific access for modification.**  For example, most pip install/conda install commands occur as the root user and result in new files in the $CONDA_DIR directory that will be owned by **root** and cause issues if user **jovyan** tried to update or uninstall these packages (as they by default will not have permission to change/remove these files).

To fix this issue, end any `RUN` command that edits any user-editable files with:

```
fix-permissions $CONDA_DIR && \
fix-permissions /home/$NB_USER
```

This fix edits the permissions of files in these locations to allow user access.  Note that if these are not applied **in the same layer as when the new files were added** it will result in a duplication of data in the layer because the act of changing permissions on a file from a previous layer requires a copy of that file into the current layer.  So something like:

```
RUN add_1GB_file_with_wrong_permissions_to_NB_USER.sh && \
	fix-permissions /home/$NB_USER
```

would add a single layer of about 1GB, whereas

```
RUN add_1GB_file_with_wrong_permissions_to_NB_USER.sh

RUN fix-permissions /home/$NB_USER
```

would add two layers, each about 1GB (2GB total).

## Structure


```
.
├── Makefile                                # Cats the docker-bits together
│
├── docker-bits                             # The docker snippets. Numbering indicates the DAG.
│   ├── 0_CPU.Dockerfile
│   ├── 1_CUDA-11.6.Dockerfile
│   ├── 1_CUDA-11.7.Dockerfile
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
└── tests
    ├── general                             # General tests applied to all images
    ├── jupyterlab-cpu                      # Test applied to a specific image
    └── jupyterlab-tensorflow


```

## Troubleshooting
If running using a VM and RStudio image was built successfully but is not opening correctly on localhost (error 5000 page), change your CPU allocation in your Linux VM settings to >= 3. You can also use your VM's system monitor to examine if all CPUs are 100% being used as your container is running. If so, increase CPU allocation. 
This was tested on Linux Ubuntu 20.04 virtual machine.
