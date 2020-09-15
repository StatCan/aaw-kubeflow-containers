# Summary

This is a Dockerfile which adds geomatics-related R packages.  Typical usage for this Dockerfile is to be built off `minimal-notebook-cpu`.  The upstream image is defined during `docker build` via `--build-arg BASE_CONTAINER`.

# Usage

## CPU

(requires you've already built the base_container locally)

```
build_cpu.sh
```

## GPU

(no tools in this notebook leverage a GPU so this is omitted)

## CI

See `.github/workflows/build-cpu.yml` for deployment versions, which use `.github/workflows/build_push.sh` to automate some tagging/pushing/caching.
