GET_AUTH_TOKEN="$(kubectl get secret trino-auth -n $NB_NAMESPACE --template={{.data.password}} | base64 -d)"
export $GET_AUTH_TOKEN