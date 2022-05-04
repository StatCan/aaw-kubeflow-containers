#!/bin/bash

# Get token from default service account
GET_TOKEN="$(kubectl describe secret default-token | grep 'token:' | sed 's/^.*://')"

#todo: Change server when deployed on dev. Placeholder for now
SERVER=https://trino.example.com

# Trino client pass in server, access token and additional options the user can configures
# todo: remove user option
trino-original --server $SERVER --insecure --access-token $GET_TOKEN --user default "$@"
