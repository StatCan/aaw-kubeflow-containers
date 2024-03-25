.PHONY: all build-jupyterlab build-jupyterlab-sas

# Paths to Dockerfiles and additional files
JUPYTERLAB_DOCKERFILE := dockerfiles/jupyterlab/Dockerfile
SAS_DOCKERFILE := dockerfiles/sas/Dockerfile
JUPYTERLAB_CONTEXT := dockerfiles/jupyterlab

# Default target
build-all: build-jupyterlab build-jupyterlab-sas

# Build jupyterlab image
build-jupyterlab:
	docker build -t zone-jupyterlab -f $(JUPYTERLAB_DOCKERFILE) $(JUPYTERLAB_CONTEXT)

# Build jupyterlab-sas image
build-jupyterlab-sas: build-jupyterlab
	docker build -t zone-jupyterlab-sas -f $(SAS_DOCKERFILE) .
