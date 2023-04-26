#!/bin/bash
if [[ $KUBERNETES_SERVICE_HOST =~ ".131." ]];
then
    # Use protb trino instance
    if [ -d "/etc/protb" ]
    then
        SERVER=http://trino-protb.trino-protb-system.svc.cluster.local
        trino-original --server $SERVER --debug  "$@"
    else
        SERVER=https://trino.aaw-dev.cloud.statcan.ca
        trino-original --server $SERVER --debug --external-authentication "$@"
    fi

# Prod cluster
else
    if [ -d "/etc/protb" ]
    then
        SERVER=http://trino-protb.aaw.cloud.statcan.ca
        trino-original --server $SERVER --debug  "$@"
    else
        SERVER=https://trino.aaw.cloud.statcan.ca
        trino-original --server $SERVER --debug --external-authentication "$@"
    fi
fi

