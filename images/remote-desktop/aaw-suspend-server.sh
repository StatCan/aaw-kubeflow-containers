#!/bin/bash
#https://github.com/StatCan/aaw-kubeflow-containers/issues/459
#https://github.com/StatCan/aaw-kubeflow-containers/issues/478

time_wait=$1
if ! [ ${time_wait:+1} ]
then
    time_wait=30
fi

echo "Waiting $time_wait seconds before shutting down server (press ctrl-c to stop shutdown)..."
sleep $time_wait

nb_server_name=`echo $NB_PREFIX | perl -pe 's/^.*\///'`
tag_date=`date +%Y-%m-%d"T"%H:%M:%SZ`

echo "Shutting down server named $nb_server_name in namespace $NB_NAMESPACE with date tag $tag_date."
kubectl annotate notebook/$nb_server_name kubeflow-resource-stopped=$tag_date -n $NB_NAMESPACE
echo "Command had return code $?."