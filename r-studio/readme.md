# Summary

This is a Dockerfile which adds R-studio and some additional R packages.  Typical usage for this Dockerfile is to be built off `minimal-notebook-cpu`.  The upstream image is defined during `docker build` via `--build-arg BASE_CONTAINER`.


## CI

For CI, see `.github/workflows/build-cpu.yml`.  It leverages the `.github/workflows/build_push.sh` wrapper for tagging, pushing and caching all at once. 