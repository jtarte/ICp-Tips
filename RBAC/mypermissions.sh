#!/bin/bash
tab_resources=("configmaps" "cronjobs.batch" "daemonsets.extensions" "deployments.apps" "deployments.extensions" "deployments.apps/rollback" "deployments.extensions/rollback" "deployments.apps/scale" "deployments.extensions/scale" "endpoints" "events" "horizontalpodautoscalers.autoscaling" "images.icp.ibm.com" "ingresses.extensions" "jobs.batch" "limitranges" "localsubjectaccessreviews.authorization.k8s.io" "namespaces" "namespaces/status" "networkpolicies.extensions" "networkpolicies.networking.k8s.io" "persistentvolumeclaims" "poddisruptionbudgets.policy" "pods" "pods/attach" "pods/exec" "pods/log" "pods/portforward" "pods/proxy" "pods/status" "replicasets.extensions" "replicasets.extensions/scale" "replicationcontrollers" "replicationcontrollers/scale" "replicationcontrollers/status" "resourcequotas" "resourcequotas/status" "rolebindings.rbac.authorization.k8s.io" "roles.rbac.authorization.k8s.io" "secrets" "serviceaccounts" "servicebindings.servicecatalog.k8s.io" "servicebindings.servicecatalog.k8s.io/status" "serviceinstances.servicecatalog.k8s.io" "serviceinstances.servicecatalog.k8s.io/status" "services" "services/proxy" "statefulsets.apps" "clusterrolebindings.rbac.authorization.k8s.io" "clusterservicebrokers.servicecatalog.k8s.io" "clusterserviceclasses.servicecatalog.k8s.io" "clusterserviceplans.servicecatalog.k8s.io" "persistentvolumes")
tab_cmd=("get" "create" "update" "delete")
# Analyze the input parameters
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
  --help)
  echo 'my priviledges help'
  echo 'The command provides information about the priviledges of user on a target namespace'
  echo ''
  echo 'usage: mypriviledges.sh [options]'
  echo 'options:'
  echo '--help this message'
  echo '-n TARGET_NAMESPACE, --namespace TARGET_NAMESPACE provide the name of target namespace'
  exit
  ;;
  -n|--namespace)
  namespace=$2
  shift
  shift
  ;;
  *)
  echo 'Wrong options'
  echo 'check the command with mypriviledges.sh --help'
  exit 1
  ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters
# test if a namespace has been retrieved
if [ -z "$namespace" ]; then
  echo 'target namespace: current context namespace'
  namespace=''
else
  echo 'target namespace: '$namespace
  namespace='-n '$namespace
fi
# print the result table header
header='resources'
for cmd in "${tab_cmd[@]}"
do
  header=$header';'$cmd
done
echo $header
# loop on resources
for rsc in "${tab_resources[@]}"
do
  line=$rsc
  # loop on commands
  for cmd in "${tab_cmd[@]}"
  do
    result=$(kubectl auth can-i $cmd $rsc $namespace)
    line=$line';'$result
  done
  # print the priviledges on the resources
  echo $line
done
