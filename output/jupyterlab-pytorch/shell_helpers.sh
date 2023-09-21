# This content is appended to ~/.bashrc and ~/.zshrc at notebook boot.
#

NAMESPACE=$(echo $NB_PREFIX | awk -F '/' '{print $3}')

cat <<EOF
                     ___   ___  _    _ _
 _   _              / _ \ / _ \| |  | | |
| |_| |__   ___    / /_\ \ /_\ \ |  | | |
| __| '_ \ / _ \   |  _  |  _  | |/\| | |
| |_| | | |  __/   | | | | | | \  /\  /_|
 \__|_| |_|\___|   \_| |_\_| |_/\/  \/(_)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Bucket
=====
Buckets have been automatically mounted to your workspace. For more information https://statcan.github.io/aaw/en/5-Storage/AzureBlobStorage/

Conda
=====

It's recommended that you use conda to create virtual environments and
to install R, Python, or Julia packages.

Python
=====

Please make use of python venv's to avoid installing over jupyterlab required
packages. Not doing so could result in your notebook becoming unusable.

Have fun!!!

EOF

# Set default location for temp JNA storage if using blob fuse filesystem for home directory
if [[ $(findmnt -n -o FSTYPE -T /home/jovyan) = 'fuse' ]]; then
  export _JAVA_OPTIONS=-Djna.tmpdir=/tmp
fi

# OpenM++ default configuraton (modifiable before starting Openm++ UI)
if [[ "$KUBERNETES_SERVICE_HOST" =~ ".131." ]]; then
  #DEV
  export OMS_MODEL_DIR=/home/jovyan/models
  export OMS_HOME_DIR=/home/jovyan/
else
  if [ -d "/etc/protb" ]; then
    export OMS_MODEL_DIR=/home/jovyan/buckets/aaw-protected-b/microsim/models
    export OMS_HOME_DIR=/home/jovyan/buckets/aaw-protected-b/microsim/
  else
    export OMS_MODEL_DIR=/home/jovyan/buckets/aaw-unclassified/microsim/models
    export OMS_HOME_DIR=/home/jovyan/buckets/aaw-unclassified/microsim/
  fi
fi

# Change to switch between multuple installed versions
#export OMPP_INSTALL_DIR=/opt/openmpp/1.15.4