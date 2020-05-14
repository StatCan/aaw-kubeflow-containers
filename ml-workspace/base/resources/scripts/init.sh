#!/bin/bash
export WORKSPACE_BASE_URL=${NB_PREFIX}
exec python ${RESOURCES_PATH}/docker-entrypoint.py
