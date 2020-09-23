# Summary

This is the base image off which all the notebook images in this repo inherit.  Typical usage for this Dockerfile is that it be built off either:

* the [jupyter docker-stacks](https://github.com/jupyter/docker-stacks) datascience notebook
* a locally built GPU-equivalent `../upstream-equivalent-notebook-gpu` that mimics the docker-stacks datascience notebook but with GPU support

This provides a common notebook setup for both CPU and GPU paths, ensuring they're synced as much as possible.  If based off the images listed above, notebook image include many common tools such as:

* python, R, and Julia
* kubeflow pipelines and kubeflow-metadata
* pandas, numpy, scipy, matplotlib, and scikit-learn
* common tools such as git, nano, vi, and emacs

## CPU

To build the CPU image, first set the `BASE_CONTAINER` in the `../build_settings.env` file to point to the appropriate docker-stacks upstream image.  Then:

```
build_cpu.sh
```

## GPU

To build the GPU image, first build `upstream-equivalent-notebook-gpu`, then do:

```
build_gpu.sh
```

## CI

For CI, see `.github/workflows/build-cpu.yml` and `.github/workflows/build-gpu.yml`.  They leverage the `.github/workflows/build_push.sh` wrapper for tagging, pushing, and caching all at once. 
