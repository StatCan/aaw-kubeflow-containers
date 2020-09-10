DOCKERFILE="./Dockerfile"

USAGE_MESSAGE="
Usage: $0 -b base_container_name -d Dockerfile -t tag
Defaults:
	dockerfile=$DOCKERFILE
"

while [[ "$#" -gt 0 ]]; do case $1 in
  -b|--base_container) BASE_CONTAINER="$2"; shift;;
  -d|--dockerfile) DOCKERFILE="$2"; shift;;
  -t|--tag) TAG="$2"; shift;;
  *) echo "Unknown parameter passed: $1" &&
    echo "$USAGE_MESSAGE"; exit 1;;
esac; shift; done

cmd="docker build -f $DOCKERFILE -t $TAG --build-arg BASE_CONTAINER=$BASE_CONTAINER ."

echo "Building with command:"
echo "$cmd"
$cmd