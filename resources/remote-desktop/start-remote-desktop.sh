#!/bin/bash

if [ -d /var/run/secrets/kubernetes.io/serviceaccount ]; then
  while ! curl -s -f http://127.0.0.1:15020/healthz/ready; do sleep 1; done
fi

test -z "$GIT_EXAMPLE_NOTEBOOKS" || git clone "$GIT_EXAMPLE_NOTEBOOKS"


if conda --help > /dev/null 2>&1; then
    conda init bash
    conda init zsh
fi

# Configure the language
if [ -n "${KF_LANG}" ]; then
    if [ "${KF_LANG}" = "en" ]; then
        export LANG="en_US.utf8"
    else
        export LANG="fr_CA.utf8"
        #  User's browser lang is set to french, open jupyterlab in french (fr_FR)
        if [ "${DEFAULT_JUPYTER_URL}" != "/rstudio" ]; then
          export LANG="fr_FR"
          lang_file="$HOME/.jupyter/lab/user-settings/@jupyterlab/translation-extension/plugin.jupyterlab-settings"
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
          ) >> $lang_file
        fi
    fi

    # VS-Code i18n stuff
    if [ "${KF_LANG}" = "fr" ]; then
        export LANG="fr_FR.UTF-8"
        export LANGUAGE="fr_FR.UTF-8"
        export LC_ALL="fr_FR.UTF-8"
        #Set the locale for vscode
        mkdir -p $HOME/.vscode
        jq -e '.locale="fr"' $HOME/.vscode/argv.json > /tmp/file.json.tmp
        mv /tmp/file.json.tmp $HOME/.vscode/argv.json
    fi
fi
# Configure KFP multi-user
if [ -n "${NB_NAMESPACE}" ]; then
mkdir -p $HOME/.config/kfp
cat <<EOF > $HOME/.config/kfp/context.json
{"namespace": "${NB_NAMESPACE}"}
EOF
fi


# Create desktop shortcuts
if [ -d $RESOURCES_PATH/desktop-files ]; then
    mkdir -p ~/.local/share/applications/ $HOME/Desktop
    echo find $RESOURCES_PATH/desktop-files/ $HOME/Desktop/
    find $RESOURCES_PATH/desktop-files/ -type f -iname "*.desktop" -exec cp {} $HOME/Desktop/ \;
    rsync $RESOURCES_PATH/desktop-files/.config/ $HOME/.config/
    find $HOME/Desktop -type f -iname "*.desktop" -exec chmod +x {} \;
    mkdir -p $HOME/.config/xfce4/xfconf/xfce-perchannel-xml/
    cp /opt/install/desktop-files/.config/xfce4/xfce4-panel.xml $HOME/.config/xfce4/xfconf/xfce-perchannel-xml/
fi

mkdir -p $HOME/.vnc
[ -f $HOME/.vnc/xstartup ] || {
    cat <<EOF > $HOME/.vnc/xstartup
#!/bin/sh

unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
startxfce4 &

# Makes an unbelievable difference in speed
(sleep 10 && xdg-settings set default-web-browser firefox.desktop) &
(sleep 10 && xfconf-query -c xfwm4 -p /general/use_compositing -s false && dconf write /org/gnome/terminal/legacy/profiles/custom-command "'/bin/bash'") &
EOF
    chmod +x $HOME/.vnc/xstartup
}

mkdir -p /tmp/vnc-socket/
VNC_SOCKET=$(mktemp /tmp/vnc-socket/vnc-XXXXXX.sock)
trap "rm -f $VNC_SOCKET" EXIT

vncserver -SecurityTypes None -rfbunixpath $VNC_SOCKET -geometry 1680x1050 :1
cat $HOME/.vnc/*.log

# Launch noVNC
(
    # cd /tmp/novnc/
    cd /usr/local/lib/python3.8/dist-packages/jupyter_desktop/share/web/noVNC-1.1.0/
    ./utils/launch.sh --web $(pwd) --vnc --unix-target=$VNC_SOCKET --listen 5678
) &

NB_PREFIX=${NB_PREFIX:-/vnc}
sed -i "s~\${NB_PREFIX}~$NB_PREFIX~g" /etc/nginx/nginx.conf

if [ -f /run/secrets/kubernetes.io/serviceaccount/namespace ]; then
    export NB_NAMESPACE=$(cat /run/secrets/kubernetes.io/serviceaccount/namespace)
fi

nginx
wait
