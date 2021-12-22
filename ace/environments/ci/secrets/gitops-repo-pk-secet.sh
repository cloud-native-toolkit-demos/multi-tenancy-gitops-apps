#!/usr/bin/env bash

set -eo pipefail

# Check variables
if [ -z ${GITOPS_PK_SECRET_NAME} ]; then echo "Please set GITOPS_PK_SECRET_NAME when running script"; exit 1; fi
if [ -z ${GIT_BASEURL} ]; then echo "Please set GIT_BASEURL when running script"; exit 1; fi
if [ -z ${SSH_PRIVATE_KEY_PATH} ]; then echo "Please set SSH_PRIVATE_KEY_PATH when running script"; exit 1; fi

SEALED_SECRET_NAMESPACE=${SEALED_SECRET_NAMESPACE:-sealed-secrets}
SEALED_SECRET_CONTOLLER_NAME=${SEALED_SECRET_CONTOLLER_NAME:-sealed-secrets}

export GITOPS_KNOWN_HOSTS=$(ssh-keyscan ${GIT_BASEURL} 2>/dev/null | base64 -w 0)
export GITOPS_PRIVATE_KEY=$(base64 -w 0 ${SSH_PRIVATE_KEY_PATH})

envsubst < gitops-repo-pk-secet.yaml_template | kubeseal \
  --scope cluster-wide \
  --controller-name=${SEALED_SECRET_CONTOLLER_NAME} \
  --controller-namespace=${SEALED_SECRET_NAMESPACE} \
  -o yaml > gitops-repo-pk-secet-${GITOPS_PK_SECRET_NAME}.yaml
