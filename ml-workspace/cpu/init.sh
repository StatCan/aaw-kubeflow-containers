#!/bin/bash
export WORKSPACE_BASE_URL=${NB_PREFIX}
exec python /resources/docker-entrypoint.py
