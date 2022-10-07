#!/bin/bash

# Get token from default service account
GET_TOKEN="$(kubectl describe secret default-token | grep 'token:' | sed 's/^.*://')"

GET_AUTH_TOKEN="$(kubectl get secret trino-auth -n $NB_NAMESPACE --template={{.data.password}} | base64 -d)"

# Use protb trino instance
if [-d "/etc/protb"]
then
    SERVER=http://trino-protb.trino-protb-system.svc.cluster.local:8080
else
    SERVER=https://trino.aaw-dev.cloud.statcan.ca
fi

export TRINO_PASSWORD=$GET_AUTH_TOKEN

# Trino client pass in server, user, access token and additional options the user can configures
trino-original --user $NB_NAMESPACE --server $SERVER --password --debug "$@"
