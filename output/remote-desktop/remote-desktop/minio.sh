#!/bin/bash
# Stops script execution if a command has an error
set -e

if ! hash minio 2>/dev/null; then
    cd /vault/secrets
    . minio-standard-tenant-1
    access_key=$MINIO_ACCESS_KEY
    secret_key=$MINIO_SECRET_KEY

    firefox --new-tab https://minio-standard-tenant-1.covid.cloud.statcan.ca/minio/login



else
    echo "minio is already installed"
fi

