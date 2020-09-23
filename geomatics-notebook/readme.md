# Summary

This is a Dockerfile which adds geomatics-related R packages.  Typical usage for this Dockerfile is to be built off `minimal-notebook-cpu`.  The upstream image is defined during `docker build` via `--build-arg BASE_CONTAINER`.

# Usage

## CPU

Note: The below build instructions require you've already built the corresponding `minimal_notebook` locally.

```
build_cpu.sh
```

## GPU

(no tools in this notebook leverage a GPU so this is omitted)

## CI

For CI, see `.github/workflows/build-cpu.yml`.  It leverages the `.github/workflows/build_push.sh` wrapper for tagging, pushing, and caching all at once. 
