#!/bin/bash

# Get token from default service account
GET_TOKEN="$(kubectl describe secret default-token | grep 'token:' | sed 's/^.*://')"

GET_AUTH_TOKEN="$(kubectl get secret trino-auth -n $NB_NAMESPACE --template={{.data.password}} | base64 -d)"

SERVER=https://trino.aaw-dev.cloud.statcan.ca

export TRINO_PASSWORD=$GET_AUTH_TOKEN

# Trino client pass in server, user, access token and additional options the user can configures
trino-original --server $SERVER --debug --catalog hive --user $NB_NAMESPACE --password "$@"
