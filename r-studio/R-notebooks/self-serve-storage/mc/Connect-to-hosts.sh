#!/bin/sh

## Note! Make sure that you enabled Minio Credential injection!
if [ ! -d /vault ]; then
	cat <<EOF 
Oh no! I think you forgot to enable Minio Credential Injection when you created the server!

Don't worry, you can just write down the names of your workspace and data volumes, delete your server,
and create a new one that attaches the old volumes, and make sure to enable Minio credential injection.

All of your data will be saved, and it will be as though nothing changed.

Exiting for now.
EOF
	exit 1
fi

for tenant in minimal premium pachyderm; do
	host=minio-$tenant
	source /vault/secrets/minio-${tenant}-tenant1 && \
		mc config host add $host $MINIO_URL $MINIO_ACCESS_KEY $MINIO_SECRET_KEY
	echo "Host $host added!"
done

cat <<EOF
Try running

    mc ls \$host/firstname-lastname


Refer to 

    mc --help


to see your options.


To get a list of hosts, run

    mc config host ls | grep '^[^ ]' | grep ''

Host List:
EOF

mc config host ls | grep '^[^ ]' | grep ''
