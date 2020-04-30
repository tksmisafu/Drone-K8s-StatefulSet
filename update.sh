#!/bin/bash

if [ -z ${PLUGIN_NAMESPACE} ]; then
  PLUGIN_NAMESPACE="default"
fi

if [ -z ${PLUGIN_KUBERNETES_USER} ]; then
  PLUGIN_KUBERNETES_USER="default"
fi

if [ ! -z ${PLUGIN_KUBERNETES_TOKEN} ]; then
  KUBERNETES_TOKEN=$PLUGIN_KUBERNETES_TOKEN
fi

if [ ! -z ${PLUGIN_KUBERNETES_SERVER} ]; then
  KUBERNETES_SERVER=$PLUGIN_KUBERNETES_SERVER
fi

if [ ! -z ${PLUGIN_KUBERNETES_CERT} ]; then
  KUBERNETES_CERT=${PLUGIN_KUBERNETES_CERT}
fi

kubectl config set-credentials default --token=${KUBERNETES_TOKEN}
if [ ! -z ${KUBERNETES_CERT} ]; then
  echo ${KUBERNETES_CERT} | base64 -d > ca.crt
  kubectl config set-cluster default --server=${KUBERNETES_SERVER} --certificate-authority=ca.crt
else
  echo "WARNING: Using insecure connection to cluster"
  kubectl config set-cluster default --server=${KUBERNETES_SERVER} --insecure-skip-tls-verify=true
fi

kubectl config set-context default --cluster=default --user=${PLUGIN_KUBERNETES_USER}
kubectl config use-context default

# kubectl version
IFS=',' read -r -a STATEFULSET <<< "${PLUGIN_STATEFULSET}"
IFS=',' read -r -a CONTAINERS <<< "${PLUGIN_CONTAINER}"
for STS in ${STATEFULSET[@]}; do
  echo Update to $KUBERNETES_SERVER
  for CONTAINER in ${CONTAINERS[@]}; do
    sed s/${CONTAINER}/PLUGIN_CONTAINER/g ./image.yaml
    sed s/${PLUGIN_REPO}/PLUGIN_REPO/g ./image.yaml
    sed s/${PLUGIN_TAG}/PLUGIN_TAG/g ./image.yaml

    kubectl -n ${PLUGIN_NAMESPACE} patch --patch "$(cat ./image.yaml)" \
      statefulset ${STS} --record
    # kubectl -n ${PLUGIN_NAMESPACE} set image deployment/${STS} \
    #   ${CONTAINER}=${PLUGIN_REPO}:${PLUGIN_TAG} --record
  done
done
