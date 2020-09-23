# Summary

This is a Dockerfile which adds Tensorflow and Pytorch.  Typical usage for this Dockerfile is to be built off either `minimal-notebook-cpu` or `minimal-notebook-gpu`, depending on whether GPU support is desired.  This provides a common notebook setup for both CPU and GPU paths, ensuring they're synced as much as possible.  The upstream image is defined during `docker build` via `--build-arg BASE_CONTAINER`.

# Usage

## CPU

Note: The below build instructions require you've already built the corresponding `minimal_notebook` locally.

```
build_cpu.sh
```

## GPU

```
build_gpu.sh
```

## CI

For CI, see `.github/workflows/build-cpu.yml` and `.github/workflows/build-gpu.yml`.  They leverage the `.github/workflows/build_push.sh` wrapper for tagging, pushing, and caching all at once. 
