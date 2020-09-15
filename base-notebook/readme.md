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

(get BASE_CONTAINER from the `../build_settings.env` file for most recent version)

```
build_cpu.sh
```

## GPU

(requires you've already built the base_container locally)

```
build_gpu.sh
```

## CI

See `.github/workflows/build-cpu.yml` and `.github/workflows/build-gpu.yml` for deployment versions, which use `.github/workflows/build_push.sh` to automate some tagging/pushing/caching.
