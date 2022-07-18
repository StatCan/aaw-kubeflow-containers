#!/bin/bash

# Get token from default service account
GET_TOKEN="$(kubectl describe secret default-token | grep 'token:' | sed 's/^.*://')"

SERVER=https://trino.aaw-dev.cloud.statcan.ca


# Trino client pass in server, user, access token and additional options the user can configures
trino-original --server $SERVER --debug "$@"
