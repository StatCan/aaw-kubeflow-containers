#!/bin/bash
# Dev cluster
if [[ $KUBERNETES_SERVICE_HOST =~ ".131." ]];
    # Use protb trino instance
    if [ -d "/etc/protb" ]
    then
        SERVER=https://trino-protb.aaw-dev.cloud.statcan.ca
    else
        SERVER=https://trino.aaw-dev.cloud.statcan.ca
    fi
then
# Prod cluster
    if [ -d "/etc/protb" ]
    then
        SERVER=https://trino-protb.aaw.cloud.statcan.ca
    else
        SERVER=https://trino.aaw.cloud.statcan.ca
    fi

# Trino client pass in server, user, access token and additional options the user can configures
trino-original --server $SERVER --debug --external-authentication "$@"
