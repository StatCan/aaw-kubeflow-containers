
# This content is appended to ~/.zshrc at notebook boot.
#
(
    cd /vault/secrets/

	for tenant in minimal premium pachyderm; do
        source minio-$tenant-tenant1
        mc config host add $tenant $MINIO_URL $MINIO_ACCESS_KEY $MINIO_SECRET_KEY
    done
) > /dev/null 2>&1

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

MinIO configured. Hosts "minimal", "premium", and "pachyderm", added.

Try

  mc ls minimal/$NAMESPACE/

Conda
=====

It's recommended that you use conda to create virtual environments and
to insall R, Python, or Julia packages.


Have fun!!!

EOF
