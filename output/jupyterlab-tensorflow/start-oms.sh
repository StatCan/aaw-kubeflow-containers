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
#
export OM_CFG_INI_ALLOW=true
export OM_CFG_INI_ANY_KEY=true
export OMS_URL=${JUPYTER_SERVER_URL}ompp

# start oms web-service
#
[ -z "$OMS_PORT" ] && OMS_PORT=4040

echo "OM_ROOT=$OM_ROOT"
echo "OMS_PORT=$OMS_PORT"
echo "OMS_URL=$OMS_URL"

OM_ROOT=$OM_ROOT ./bin/oms -l localhost:${OMS_PORT} -oms.ModelDir /home/jovyan/models -oms.HomeDir /home/jovyan/ -oms.AllowDownload -oms.AllowUpload -oms.AllowMicrodata -oms.LogRequest
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
