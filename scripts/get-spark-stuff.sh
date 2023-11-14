#!/bin/sh

help () {
    cat <<EOF
get-spark-stuff.sh
==================

Grab some Spark dockerfile stuff from these two spots

jupyter/docker-stacks
├─ all-spark-notebook/Dockerfile
└─ pyspark-notebook/Dockerfile

    usage: get-spark-stuff.sh --commit COMMIT_SHA
EOF
}

while test -n "$1"; do
    case "$1" in
        --commit|-c)
            shift
            COMMIT=$1
            ;;
        *)
            echo "Error: Unrecognized option." >&2
            help
            exit 1
            ;;
    esac
    shift
done


if test -z "$COMMIT"; then
    echo "No commit specified. Exiting." >&2
    exit 1
fi

# pyspark-notebook or all-spark-notebook
get_file () {
    FILE=$1
    COMMIT=$2

    case $FILE in
        pyspark-notebook|all-spark-notebook) ;;
        *)
            echo "Error: unrecognized." >&2
            exit 1
            ;;
    esac

    cat <<EOF
###########################
### $FILE
###########################
# https://raw.githubusercontent.com/jupyter/docker-stacks/$COMMIT/images/$FILE/Dockerfile

$(curl -s https://raw.githubusercontent.com/jupyter/docker-stacks/$COMMIT/images/$FILE/Dockerfile)

EOF
}



cat <<EOF | grep -v '^\(FROM\|ARG BASE_CONTAINER\|LABEL maintainer\)' # > 2_Spark.Dockerfile
# Spark stuff

$(get_file pyspark-notebook $COMMIT)

$(get_file all-spark-notebook $COMMIT)
EOF
