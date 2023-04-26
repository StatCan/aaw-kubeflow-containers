#!/bin/bash
if [[ $KUBERNETES_SERVICE_HOST =~ ".131." ]];
then
    # Use protb trino instance
    if [ -d "/etc/protb" ]
    then
        SERVER=http://trino-protb.trino-protb-system.svc.cluster.local
    else
        SERVER=https://trino.aaw-dev.cloud.statcan.ca
    fi
# Prod cluster
else
    if [ -d "/etc/protb" ]
    then
        SERVER=http://trino-protb.aaw.cloud.statcan.ca
    else
        SERVER=https://trino.aaw.cloud.statcan.ca
    fi
fi
# Trino client pass in server, user, access token and additional options the user can configures
trino-original --server $SERVER --debug --external-authentication "$@"
