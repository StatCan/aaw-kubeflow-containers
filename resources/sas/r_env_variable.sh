# Find the env variable, add it to the REnviron file

echo "NB_PREFIX=${1}" >> /opt/conda/lib/R/etc/Renviron && \
echo "NB_NAMESPACE=${2}" >> /opt/conda/lib/R/etc/Renviron && \
echo "Meow=test" >> /opt/conda/lib/R/etc/Renviron && \
echo "WOOF=${3}" >> /opt/conda/lib/R/etc/Renviron