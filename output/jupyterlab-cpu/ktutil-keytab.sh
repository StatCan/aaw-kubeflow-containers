#!/bin/bash
# creates the kerberos directory if not exist
mkdir -p ~/krb5
cd ~/krb5

# gets the user's username (legacy AD)
read -p "Username(ex. marcoma):" user_name

user_name="${user_name}@STATCAN.CA"
# gets the user's password
read -sp "Password for ${user_name}:" user_pass

# deletes the password prompt for cleaner output
echo -en "\r\e[K"

{
# adds entry for user, and requests password
echo "addent -password -p ${user_name} -k 1 -e RC4-HMAC";
# give password entered by user to ktutil
echo "$user_pass"
# creates keytab file
echo "wkt client.keytab";
} | ktutil

# get the current namespace
NS=$(kubectl get sa -o=jsonpath='{.items[0]..metadata.namespace}')

# generate the secret
kubectl create secret generic kerberos-keytab -n $NS --from-file=./client.keytab -o yaml --dry-run=client > ktutil_keytab.yaml

# apply the secret
kubectl apply -f ./ktutil_keytab.yaml


#get the notebook name
nb_name=${NB_PREFIX##*/}

# Prompt user for notebook restart
while true; do
    read -p "In order to update the kerberos authentication, the notebook server needs to be restarted. Would you like to restart your notebook server?[Y/n]: " yn
    case $yn in
        [Yy]* ) echo "Your notebook server will now restart"; kubectl rollout restart statefulset $nb_name -n $NB_NAMESPACE; break;;
        [Nn]* ) echo "Your notebook server will not be restarted"; exit;;
        * ) echo "Only yes or no is an expected answer";;
    esac
done
