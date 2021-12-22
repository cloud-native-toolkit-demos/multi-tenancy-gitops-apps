#!/usr/bin/env bash

set -eo pipefail

# Check variables
if [ -z ${NAME} ]; then echo "Please set NAME  when running script"; exit 1; fi
if [ -z ${GIT_BASEURL} ]; then echo "Please set GIT_BASEURL when running script"; exit 1; fi
if [ -z ${SSH_PRIVATE_KEY_PATH} ]; then echo "Please set SSH_PRIVATE_KEY_PATH when running script"; exit 1; fi

SEALED_SECRET_NAMESPACE=${SEALED_SECRET_NAMESPACE:-sealed-secrets}
SEALED_SECRET_CONTOLLER_NAME=${SEALED_SECRET_CONTOLLER_NAME:-sealed-secrets}

KNOWN_HOSTS=$(ssh-keyscan ${GIT_BASEURL} 2>/dev/null | base64 -w 0)
PRIVATE_KEY=$(base64 -w 0 ${SSH_PRIVATE_KEY_PATH})

kubeseal \
  --scope cluster-wide \
  --controller-name=${SEALED_SECRET_CONTOLLER_NAME} \
  --controller-namespace=${SEALED_SECRET_NAMESPACE} \
  -o yaml << EOF > git-ssh-pk-${NAME}.yaml
kind: Secret
apiVersion: v1
metadata:
  name: ${NAME}
  annotations:
    tekton.dev/git-0: ${GIT_BASEURL}
type: kubernetes.io/ssh-auth
data:
  ssh-privatekey: ${PRIVATE_KEY}
  known_hosts: ${KNOWN_HOSTS}
EOF
