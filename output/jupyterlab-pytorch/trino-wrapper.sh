#!/bin/bash

# Use protb trino instance
GET_CONTEXT="$(kubectl get po -l trino-version=dev -n trino-system -o json | jq '.items[] |"\(.metadata.name)"')"
if [[ $GET_CONTEXT == *"dev"* ]]; then
    if [[ -d "/etc/protb" ]]; then
        SERVER=https://trino-protb.aaw-dev.cloud.statcan.ca
    else
        SERVER=https://trino.aaw-dev.cloud.statcan.ca
    fi
else
    if [[ -d "/etc/protb" ]]; then
        SERVER=https://trino-protb.aaw.cloud.statcan.ca
    else
        SERVER=https://trino.aaw.cloud.statcan.ca
    fi
fi

# Trino client pass in server, user, access token and additional options the user can configures
trino-original --server $SERVER --debug --external-authentication "$@"
