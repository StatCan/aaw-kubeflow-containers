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

MinIO
=====

MinIO configured. Hosts "standard" and "premium" added as mounted drives.

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

# Activate the base python venv by default
source $HOME/base-python-venv/bin/activate
