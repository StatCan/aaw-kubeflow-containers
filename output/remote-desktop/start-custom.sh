#!/bin/bash

if [ -d /var/run/secrets/kubernetes.io/serviceaccount ]; then
  while ! curl -s -f http://127.0.0.1:15020/healthz/ready; do sleep 1; done
fi

echo "--------------------start-custom.sh starting, it is ready--------------------"

#No for now
#test -z "$GIT_EXAMPLE_NOTEBOOKS" || git clone "$GIT_EXAMPLE_NOTEBOOKS"

# Configure the shell! If not already configured.
if [ ! -f /home/$NB_USER/.zsh-installed ]; then
    if [ -f /tmp/oh-my-zsh-install.sh ]; then
      sh /tmp/oh-my-zsh-install.sh --unattended --skip-chsh
    fi

    if conda --help > /dev/null 2>&1; then
      conda init bash
      conda init zsh
    fi
    cat /tmp/shell_helpers.sh >> /home/$NB_USER/.bashrc
    cat /tmp/shell_helpers.sh >> /home/$NB_USER/.zshrc
    touch /home/$NB_USER/.zsh-installed
fi

echo "shell has been configured"

# create .profile
cat <<EOF > $HOME/.profile
if [ -n "$BASH_VERSION" ]; then
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi
EOF

echo ".profile has been created"

# Configure the language
if [ -n "${KF_LANG}" ]; then
    if [ "${KF_LANG}" = "en" ]; then
        export LANG="en_US.utf8"
    else
        export LANG="fr_CA.utf8"
        #  User's browser lang is set to French, open jupyterlab and vs_code in French (fr_FR)
        if [ "${DEFAULT_JUPYTER_URL}" != "/rstudio" ]; then
          export LANG="fr_FR"
          lang_file="/home/${NB_USER}/.jupyter/lab/user-settings/@jupyterlab/translation-extension/plugin.jupyterlab-settings"
          mkdir -p "$(dirname "${lang_file}")" && touch $lang_file
          ( echo    '{'
            echo     '   // Langue'
            echo     '   // @jupyterlab/translation-extension:plugin'
            echo     '   // Paramètres de langue.'
            echo  -e '   // ****************************************\n'
            echo     '   // Langue locale'
            echo     '   // Définit la langue d'\''affichage de l'\''interface. Exemples: '\''es_CO'\'', '\''fr'\''.'
            echo     '   "locale": "'${LANG}'"'
            echo     '}'
          ) > $lang_file
          vscode_language="${XDG_DATA_HOME}/code-server/User/argv.json"
          echo "{\"locale\":\"fr\"}" >> $vscode_language
        fi
    fi
fi

echo "language has been configured"

# Configure KFP multi-user
if [ -n "${NB_NAMESPACE}" ]; then
mkdir -p $HOME/.config/kfp
cat <<EOF > $HOME/.config/kfp/context.json
{"namespace": "${NB_NAMESPACE}"}
EOF
fi

echo "KFP multi-user has been configured"

# Introduced by RStudio 1.4
# See https://github.com/jupyterhub/jupyter-rsession-proxy/issues/95
# And https://github.com/blairdrummond/jupyter-rsession-proxy/blob/master/jupyter_rsession_proxy/__init__.py
export RSERVER_WWW_ROOT_PATH=$NB_PREFIX/rstudio

# Remove a Jupyterlab 2.x config setting that breaks Jupyterlab 3.x
NOTEBOOK_CONFIG="$HOME/.jupyter/jupyter_notebook_config.json"
NOTEBOOK_CONFIG_TMP="$HOME/.jupyter/jupyter_notebook_config.json.tmp"

if [ -f "$NOTEBOOK_CONFIG" ]; then
  jq 'del(.NotebookApp.server_extensions)' "$NOTEBOOK_CONFIG" > "$NOTEBOOK_CONFIG_TMP" \
      && mv -f "$NOTEBOOK_CONFIG_TMP" "$NOTEBOOK_CONFIG"
fi

echo "broken configuration settings removed"

export NB_NAMESPACE=$(echo $NB_PREFIX | awk -F '/' '{print $3}')
export JWT="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)"

printenv | grep KUBERNETES >> /opt/conda/lib/R/etc/Renviron
#mkdir -p vscode-settings
# VS_CODE_SETTINGS=/etc/share/code-server/Machine/settings.json
# VS_CODE_PRESISTED=$HOME/vscode-settings/share/code-server/Machine/settings.json
# if [-f "$VS_CODE_PRESISTED" ]; then
#     cp "$VS_CODE_PRESISTED" "$VS_CODE_SETTINGS"
# else
#     cp vscode-overrides.json "$VS_CODE_SETTINGS"
# fi

echo "--------------------starting jupyter--------------------"

/opt/conda/bin/jupyter server --notebook-dir=/home/${NB_USER} \
                 --ip=0.0.0.0 \
                 --no-browser \
                 --port=8888 \
                 --ServerApp.token='' \
                 --ServerApp.password='' \
                 --ServerApp.allow_origin='*' \
                 --ServerApp.authenticate_prometheus=False \
                 --ServerApp.base_url=${NB_PREFIX} \
                 --ServerApp.default_url=${DEFAULT_JUPYTER_URL:-/tree}

echo "--------------------shutting down--------------------"
# persist vscode server remote settings (Machine dir)
#VS_CODE_SETTINGS_PERSIST=$HOME/vscode-settings/share/code-server/Machine/settings.json
#cp $VS_CODE_SETTINGS $VS_CODE_SETTINGS_PERSIST
