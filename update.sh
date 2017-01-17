#!/bin/sh

if [ -z ${PLUGIN_NAMESPACE} ]; then
  PLUGIN_NAMESPACE="default"
fi

kubectl config set-credentials default --token=${KUBERNETES_TOKEN}
kubectl config set-cluster default --server=${KUBERNETES_SERVER} --insecure-skip-tls-verify=true
kubectl config set-context default --cluster=default --user=default
kubectl config use-context default
kubectl -n ${PLUGIN_NAMESPACE} set image deployment/${PLUGIN_DEPLOYMENT} ${PLUGIN_CONTAINER}=${PLUGIN_REPO}:${PLUGIN_TAG}