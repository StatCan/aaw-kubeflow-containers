#!/usr/bin/env bash
#
# It does:
#   ulimit -S -s 65536
#   OM_ROOT=${OM_ROOT} bin/oms -oms.Listen http://localhost:${OMS_PORT} -oms.HomeDir models/home -oms.AllowDownload -oms.AllowUpload -oms.AllowMicrodata -oms.LogRequest
#
# Environment:
#   OM_ROOT  - openM++ root folder, default: current directory
#   OMS_PORT - oms web-service port to listen, default: 4040

# set -e
set -m

# large models may require stack limit increase
#
ulimit -S -s 65536
status=$?

if [ $status -ne 0 ] ;
then
  echo "FAILED to set: ulimit -S -s 65536"
  echo -n "Press Enter to exit..."
  read any
  exit $status
fi

# set openM++ root folder 
#
self=$(basename $0)

OM_ROOT="$OMPP_INSTALL_DIR"

[ "$OM_ROOT" != "$PWD" ] && pushd $OM_ROOT

# allow to use $MODEL_NAME.ini file in UI for model run
export OM_CFG_INI_ALLOW=true
export OM_CFG_INI_ANY_KEY=true
export OMS_URL=${JUPYTER_SERVER_URL}ompp

# # OpenM++ default configuraton
# if [ "$KUBERNETES_SERVICE_HOST" =~ ".131." ] || [ -z $KUBERNETES_SERVICE_HOST ]; then
#   #DEV or Localhost
#   export OMS_MODEL_DIR=/home/jovyan/models
#   export OMS_LOG_DIR=/home/jovyan/logs
#   export OMS_HOME_DIR=/home/jovyan/
# else
#   if [ -d "/etc/protb" ]; then
#     export OMS_MODEL_DIR=/home/jovyan/buckets/aaw-protected-b/microsim/models
#     export OMS_LOG_DIR=/home/jovyan/buckets/aaw-protected-b/microsim/logs
#     export OMS_HOME_DIR=/home/jovyan/buckets/aaw-protected-b/microsim/
#   else
#     export OMS_MODEL_DIR=/home/jovyan/buckets/aaw-unclassified/microsim/models
#     export OMS_LOG_DIR=/home/jovyan/buckets/aaw-unclassified/microsim/logs
#     export OMS_HOME_DIR=/home/jovyan/buckets/aaw-unclassified/microsim/
#   fi
# fi

export OMS_MODEL_DIR=/home/jovyan/mpi-test
export OMS_LOG_DIR=/home/jovyan/buckets/aaw-protected-b/microsim/logs
export OMS_HOME_DIR=/home/jovyan/buckets/aaw-protected-b/microsim


# Create models directory if it doesn't exist:
if [ ! -d "$OMS_MODEL_DIR" ]; then
  mkdir -p "$OMS_MODEL_DIR"
fi

# Create model log directory if it doesn't exist:
if [ ! -d "$OMS_LOG_DIR" ]; then
  mkdir -p "$OMS_LOG_DIR"
fi

# Copy sample models from openmpp installation archive into models directory:
# cp -r "$OMPP_INSTALL_DIR/models/." "$OMS_MODEL_DIR"

# These three environment variables don't persist so let's try using a file:
echo "$OMS_HOME_DIR" > $OM_ROOT/etc/oms_home_dir 
echo "$OMS_MODEL_DIR" > $OM_ROOT/etc/oms_model_dir 
echo "$OMS_LOG_DIR" > $OM_ROOT/etc/oms_log_dir


# Import openmpp repo to get scripts and templates needed to run mpi jobs via kubeflow:
if [ ! -d /openmpp ]
 then
  git clone https://github.com/StatCan/openmpp.git
fi
cd openmpp
branch="main"
state=$(git symbolic-ref --short HEAD 2>&1)
if [ $state != $branch ]
 then
  git checkout $branch
fi 
git pull
cd mpi-job-files

# Copy scripts and templates into openmpp installation bin and etc folders:
cp dispatchMPIJob.sh parseCommand.py "$OM_ROOT/bin/"
cp mpi.kubeflow.template.txt MPIJobTemplate.yaml "$OM_ROOT/etc/"

# Delete the default mpi golang template that does not work in our context:
rm -f "$OM_ROOT/etc/mpi.ModelRun.template.txt"

# Making sure these can execute:
chmod +x dispatchMPIJob.sh parseCommand.py

# Remove repo as it's not needed anymore:
cd "$OM_ROOT" && rm -rf openmpp

# Output various oms settings to console:
[ -z "$OMS_PORT" ] && OMS_PORT=4040

echo "OM_ROOT=$OM_ROOT"
echo "OMS_PORT=$OMS_PORT"
echo "OMS_URL=$OMS_URL"

echo "OMS_MODEL_DIR=$OMS_MODEL_DIR"
echo "OMS_HOME_DIR=$OMS_HOME_DIR"
echo "OMS_LOG_DIR=$OMS_LOG_DIR"


# start oms web-service:
OM_ROOT=$OM_ROOT ${OM_ROOT}/bin/oms -l localhost:${OMS_PORT} -oms.ModelDir ${OMS_MODEL_DIR} -oms.HomeDir ${OMS_HOME_DIR} -oms.ModelLogDir ${OMS_LOG_DIR} -oms.AllowDownload -oms.AllowUpload -oms.AllowMicrodata -oms.LogRequest -OpenM.LogToFile -OpenM.LogUseDailyStamp -OpenM.LogFilePath ${OM_ROOT}/log/oms.log

status=$?
if [ $status -ne 0 ] ;
then
  [ $status -eq 130 ] && echo " oms web-service terminated by Ctrl+C"
  [ $status -ne 130 ] && echo " FAILED to start oms web-service"
fi

echo "."
echo -n "Press Enter to exit..."
read any
exit $status
