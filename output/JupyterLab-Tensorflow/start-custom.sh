#!/bin/bash

if [ -d /var/run/secrets/kubernetes.io/serviceaccount ]; then
  while ! curl -s -f http://127.0.0.1:15020/healthz/ready; do sleep 1; done
fi

test -z "$GIT_EXAMPLE_NOTEBOOKS" || git clone "$GIT_EXAMPLE_NOTEBOOKS"

# Configure the shell! If not already configured.
if [ ! -f /home/$NB_USER/.zsh-installed ]; then
    if [ -f /tmp/oh-my-zsh-install.sh ]; then
      sh /tmp/oh-my-zsh-install.sh --unattended --skip-chsh
    fi

    if conda --help > /dev/null 2>&1; then
      conda init bash
      conda init zsh
    fi

    cat /tmp/helpers.sh >> /home/$NB_USER/.bashrc
    cat /tmp/helpers.sh >> /home/$NB_USER/.zshrc
    touch /home/$NB_USER/.zsh-installed
fi

# Configure the language
if [ -n "${KF_LANG}" ]; then
    if [ "${KF_LANG}"="en" ]; then
        LANG="en_US.utf8"
    else
        LANG="fr_CA.utf8"
    fi
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
