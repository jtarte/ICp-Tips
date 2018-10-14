#! /bin/bash

help()
{
  echo 'command configureICPKubeCli'
  echo 'configureICPKubeCli PARAMS ...  '
  echo '-c clustername the name of the ICP cluster. Optional parameter. Default value is mycluster.icp'
  echo '-n namespace the target namespace. Optional parameter. Default value is default'
  echo '-u username the name of the user'
  echo '-p password the password of the cluster'
  echo '-s server. THE IP or hostname of the ICP management'
  echo '-h this message. Help message'
  exit 1
}

NAMESPACE="default"
CLUSTER="mycluster.icp"

while getopts u:p:c:n:s:h option
do
  case "${option}"
  in
    u) ICPUSER=${OPTARG};;
    c) CLUSTER=${OPTARG};;
    p) ICPPASSWORD=${OPTARG};;
    n) NAMESPACE=${OPTARG};;
    s) SERVER=${OPTARG};;
    h)
      help
      ;;
    :)
      echo "option $OPTARG needs a value"
      help
      ;;
    \?)
      echo "$OPTARG : invalide option"
      help
      ;;
  esac
done

if [ -z $ICPUSER ]
then
  echo "Missing username (option -u)"
  help
fi
if [ -z $ICPPASSWORD ]
then
  echo "Missing pasword (option -p)"
  help
fi
if [ -z $SERVER ]
then
  echo "Missing host (option -s)"
  help
fi

echo "Retrieving security token for user: ${ICPUSER} on cluster: ${CLUSTER} at host: ${SERVER}"
## Retrieve the id token
TOKEN=$(curl -k -X POST "https://${SERVER}:8443/idprovider/v1/auth/identitytoken" -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" -d "grant_type=password&username=${ICPUSER}&password=${ICPPASSWORD}&scope=openid" --insecure | jq --raw-output .id_token)
if [ -z $TOKEN ]
then
  echo 'Error during user authentication'
  exit 1
fi
echo
echo Setting kubectl enviroment
echo
## execute kubectl commands to connect to ICP environment
kubectl config set-cluster "${CLUSTER}" --server="https://${SERVER}:8001" --insecure-skip-tls-verify=true
kubectl config set-context "${CLUSTER}-context" --cluster="${CLUSTER}"
kubectl config set-credentials "${ICPUSER}" --token="${TOKEN}"
kubectl config set-context "${CLUSTER}-context" --user="${ICPUSER}" --namespace="${NAMESPACE}"
kubectl config use-context "${CLUSTER}-context"
echo
echo 'Configuration completed'
echo 'Try kubectl get pods'
echo
exit 0
