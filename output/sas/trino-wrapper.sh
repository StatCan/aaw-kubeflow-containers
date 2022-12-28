#!/bin/bash

# Use protb trino instance
if [ -d "/etc/protb" ]
then
    SERVER=http://trino-protb.trino-protb-system.svc.cluster.local:8080
else
    SERVER=https://trino.aaw-dev.cloud.statcan.ca
fi


# Trino client pass in server, user, access token and additional options the user can configures
trino-original --server $SERVER --debug --external-authentication "$@"
