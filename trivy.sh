TRIVY_VERSION="v0.56.2"
TRIVY_DATABASES='"ghcr.io/aquasecurity/trivy-db:2","public.ecr.aws/aquasecurity/trivy-db"'
TRIVY_JAVA_DATABASES='"ghcr.io/aquasecurity/trivy-java-db:1","public.ecr.aws/aquasecurity/trivy-java-db"'
TRIVY_MAX_RETRIES=10
TRIVY_RETRY_DELAY=20
FULL_IMAGE_NAME="k8scc01covidacr.azurecr.io/jupyterlab-cpu"

# Install Trivy
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin "$TRIVY_VERSION"

# Loop to attempt Trivy scan with retries
for ((i=0; i<TRIVY_MAX_RETRIES; i++)); do
  echo "Attempt $((i + 1)) of $TRIVY_MAX_RETRIES..."

  # Run Trivy scan
  trivy image \
    --db-repository "$TRIVY_DATABASES" \
    --java-db-repository "$TRIVY_JAVA_DATABASES" \
    "$FULL_IMAGE_NAME" \
    --exit-code 10 --timeout=20m --scanners vuln --severity CRITICAL
  EXIT_CODE=$?

  if [[ $EXIT_CODE -eq 0 ]]; then
    echo "Trivy scan completed successfully."
    exit 0
  elif [[ $EXIT_CODE -eq 10 ]]; then
    echo "Trivy scan completed successfully. Some vulnerabilities were found."
    exit 10
  elif [[ $i -lt $((TRIVY_MAX_RETRIES - 1)) ]]; then
    echo "Encountered unexpected error. Retrying in $TRIVY_RETRY_DELAY seconds..."
    sleep "$TRIVY_RETRY_DELAY"
  else
    echo "Unexpected error persists after $TRIVY_MAX_RETRIES attempts. Exiting."
    exit 1
  fi
done