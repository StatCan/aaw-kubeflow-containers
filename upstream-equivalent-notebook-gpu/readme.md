# Summary

This generates a Dockerfile that is equivalent to the [jupyter docker-stacks](https://github.com/jupyter/docker-stacks) CPU-only datascience notebook, except that this also includes NVIDIA CUDA drivers installed to support GPU usage.  [gpu-jupyter](https://github.com/iot-salzburg/gpu-jupyter) is used to produce this GPU-version Dockerfile. 

This image is used as the "upstream" image equivalent for the base-notebook-gpu.

# Build Instructions

## Set up environment
Ensure `../build_settings.env` points to the docker-stacks and gpu-jupyter commit hashes you want.  This will decide which Dockerfiles and adaptation scripts are used during the Dockerfile generation.  You can also pass these as arguments to `create_dockerfile.sh` directly.

## Create and Build the Dockerfile

### Via Script

Run `build.sh` which should walk through the entire process.

### Manually

Create the Dockerfile using:

```
create_dockerfile.sh
```

This will: 

* clone docker-stacks and set the head to the desired commit
* clone gpu-jupyter and set the head to the desired commit
* run gpu-jupyter/generate-Dockerfile.sh and copy products back to ./

Build the Dockerfile using:

```
IMAGE_TAG="upstream-equivalent-notebook-gpu"
docker build -t $IMAGE_TAG .
```

For CI, see `.github/workflows/build-cpu.yml` and `.github/workflows/build-gpu.yml`.  They leverage the `.github/workflows/build_push.sh` wrapper for tagging, pushing, and caching all at once. 
