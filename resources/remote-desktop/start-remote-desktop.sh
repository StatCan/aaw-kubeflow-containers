#!/bin/bash

if [ -d /var/run/secrets/kubernetes.io/serviceaccount ]; then
  while ! curl -s -f http://127.0.0.1:15020/healthz/ready; do sleep 1; done
fi

# Configure the language
# Note that our inherited image already has settings for en_US
if [ -n "${KF_LANG}" ]; then
    if [ "${KF_LANG}" = "fr" ]; then
        export LANG="fr_FR.UTF-8"
        export LANGUAGE="fr_FR.UTF-8"
        export LC_ALL="fr_FR.UTF-8"
        #Set the locale for vscode
        jq -e '.locale="fr"' /home/$NB_USER/.vscode/argv.json > file.json.tmp && cp file.json.tmp /home/$NB_USER/.vscode/argv.json
    fi
fi
# Configure KFP multi-user
if [ -n "${NB_NAMESPACE}" ]; then
mkdir -p $HOME/.config/kfp
cat <<EOF > $HOME/.config/kfp/context.json
{"namespace": "${NB_NAMESPACE}"}
EOF
fi

jupyter notebook --notebook-dir=/home/${NB_USER} \
                 --ip=0.0.0.0 \
                 --no-browser \
                 --port=8888 \
                 --NotebookApp.token='' \
                 --NotebookApp.password='' \
                 --NotebookApp.allow_origin='*' \
                 --NotebookApp.base_url=${NB_PREFIX} \
                 --NotebookApp.default_url=${DEFAULT_JUPYTER_URL:-/tree}
