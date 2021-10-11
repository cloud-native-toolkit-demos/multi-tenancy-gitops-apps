#!/usr/bin/env bash

set -eo pipefail

# Set variables
if [ -z ${GIT_BASEURL} ]; then echo "Please set GIT_BASEURL when running script"; exit 1; fi
if [ -z ${GIT_USER} ]; then echo "Please set GIT_USER when running script"; exit 1; fi
if [ -z ${GIT_TOKEN} ]; then echo "Please set GIT_TOKEN when running script"; exit 1; fi


SEALED_SECRET_NAMESPACE=${SEALED_SECRET_NAMESPACE:-sealed-secrets}
SEALED_SECRET_CONTOLLER_NAME=${SEALED_SECRET_CONTOLLER_NAME:-sealed-secrets}

# Create Kubernetes Secret yaml
cat <<EOF > delete-git-credentials-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: git-credentials-ace
  annotations:
    tekton.dev/git-0: ${GIT_BASEURL}
type: kubernetes.io/basic-auth
stringData:
  username: ${GIT_USER}
  password: ${GIT_TOKEN}
EOF

# Encrypt the secret using kubeseal and private key from the cluster
kubeseal --scope cluster-wide --controller-name=${SEALED_SECRET_CONTOLLER_NAME} --controller-namespace=${SEALED_SECRET_NAMESPACE} -o yaml < delete-git-credentials-secret.yaml > git-credentials-secret.yaml

# NOTE, do not check delete-ibm-entitled-key-secret.yaml into git!
rm delete-git-credentials-secret.yaml
