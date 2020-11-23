# Summary

This is a minimally populated image to be deployed on the DAaaS platform.  It adds tools such as:

* `kubectl`, `minio`, and `az`
* Some common jupyterlab extensions

Typical usage for this Dockerfile is to be built off a `base-notebook-cpu` or `base-notebook-gpu` image, depending on whether GPU support is desired.  This provides a common notebook setup for both CPU and GPU paths, ensuring they're synced as much as possible.  The upstream image is defined during `docker build` via `--build-arg BASE_CONTAINER`.


## CI

For CI, see `.github/workflows/build-cpu.yml` and `.github/workflows/build-gpu.yml`.  They leverage the `.github/workflows/build_push.sh` wrapper for tagging, pushing and caching all at once. 