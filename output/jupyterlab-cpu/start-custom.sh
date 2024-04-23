#!/bin/bash

echo "--------------------Starting up--------------------"
if [ -d /var/run/secrets/kubernetes.io/serviceaccount ]; then
  while ! curl -s -f http://127.0.0.1:15020/healthz/ready; do sleep 1; done
fi

echo "Checking if we want to sleep infinitely"
if [[ -z "${INFINITY_SLEEP}" ]]; then
  echo "Not sleeping"
else
  echo "--------------------zzzzzz--------------------"
  sleep infinity
fi

test -z "$GIT_EXAMPLE_NOTEBOOKS" || git clone "$GIT_EXAMPLE_NOTEBOOKS"

if [ ! -e /home/$NB_USER/.Rprofile ]; then
    cat /tmp/.Rprofile >> /home/$NB_USER/.Rprofile && rm -rf /tmp/.Rprofile
fi

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
    touch /home/$NB_USER/.hushlogin
fi

export VISUAL="/usr/bin/nano"
export EDITOR="$VISUAL"

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
          vscode_language="${CS_DEFAULT_HOME}/User/argv.json"
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

# Revert forced virtualenv, was causing issues with users
#export PIP_REQUIRE_VIRTUALENV=true
#echo "Checking if Python venv exists"
#if [[ -d "base-python-venv" ]]; then
#  echo "Base python venv exists, not going to create again"
#else
#  echo "Creating python venv"
#  python3 -m venv $HOME/base-python-venv
#  echo "adding include-system-site-packages"
#fi

echo "Checking for .condarc file in hom directory"
if [[ -f "$HOME/.condarc" ]]; then
  echo ".condarc file exists, not going to do anything"
else
  echo "Creating basic .condarc file"
  printf 'envs_dirs:\n  - $HOME/.conda/envs' > $HOME/.condarc
fi

printenv | grep KUBERNETES >> /opt/conda/lib/R/etc/Renviron

# Copy default config and extensions on first start up
if [ ! -d "$CS_DEFAULT_HOME/Machine" ]; then
  echo "Creating code-server default settings and extentions"
  mkdir -p "$CS_DEFAULT_HOME"
  cp -r "$CS_TEMP_HOME/." "$CS_DEFAULT_HOME"
fi

# Retrieve service account details
serviceaccountname=`kubectl get secret artifactory-creds -n $NB_NAMESPACE --template={{.data.Username}} | base64 --decode`
serviceaccounttoken=`kubectl get secret artifactory-creds -n $NB_NAMESPACE --template={{.data.Token}} | base64 --decode`
conda config --add channels https://$serviceaccountname:$serviceaccounttoken@artifactory.cloud.statcan.ca/artifactory/rpug-conda/
conda config --remove channels 'defaults'

pip config set global.index-url https://$serviceaccountname:$serviceaccounttoken@artifactory.cloud.statcan.ca/artifactory/api/pypi/pypi-remote/simple

# if rprofile doesnt exist
if [ ! -d "/opt/conda/lib/R/etc/Rprofile.site" ]; then
  echo "Creating rprofile"
  cat > /opt/conda/lib/R/etc/Rprofile.site<< EOF
options(jupyter.plot_mimetypes = c('text/plain', 'image/png', 'image/jpeg', 'image/svg+xml', 'application/pdf'))
local({
  r <- list("cran-remote" = "https://$serviceaccountname:$serviceaccounttoken@artifactory.cloud.statcan.ca/artifactory/rpug-cran/")
  options(repos = r)
})
EOF
fi

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

echo "--------------------shutting down, persisting VS_CODE settings--------------------"
