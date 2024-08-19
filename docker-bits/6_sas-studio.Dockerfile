# Jupyter SASStudio Proxy
COPY jupyter-sasstudio-proxy/ /opt/jupyter-sasstudio-proxy/
RUN pip install /opt/jupyter-sasstudio-proxy/

# Adds default workspace shortcut to sasstudio
COPY SWE.folderShortcuts.key /etc/sasstudio/preferences/SWE.folderShortcuts.key

# Enable X command on SAS Studio
COPY spawner_usermods.sh /usr/local/SASHome/studioconfig/spawner/