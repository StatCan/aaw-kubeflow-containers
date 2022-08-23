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


Have fun!!!

EOF

# Set default location for temp JNA storage if using blob fuse filesystem for home directory
if [[ $(findmnt -n -o FSTYPE -T /home/jovyan) = 'fuse' ]]; then
  export _JAVA_OPTIONS=-Djna.tmpdir=/tmp
fi
