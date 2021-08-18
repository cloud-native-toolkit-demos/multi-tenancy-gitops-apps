#!/usr/bin/env bash

# Set variables
if [[ -z ${GIT_USER} ]]; then
  echo "Please provide environment variable GIT_USER"
  exit 1
fi

if [[ -z ${GIT_TOKEN} ]]; then
  echo "Please provide environment variable GIT_TOKEN"
  exit 1
fi

SEALED_SECRET_NAMESPACE=${SEALED_SECRET_NAMESPACE:-sealed-secrets}

# Create Kubernetes Secret yaml
cat <<EOF > delete-git-credentials-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: git-credentials
  annotations:
    tekton.dev/git-0: https://github.com
type: kubernetes.io/basic-auth
stringData:
  username: ${GIT_USER}
  password: ${GIT_TOKEN}
EOF

# Encrypt the secret using kubeseal and private key from the cluster
kubeseal --scope cluster-wide --controller-name=sealedsecretcontroller-sealed-secrets --controller-namespace=${SEALEDSECRET_NAMESPACE} -o yaml < delete-git-credentials-secret.yaml > git-credentials-secret.yaml

# NOTE, do not check delete-ibm-entitled-key-secret.yaml into git!
rm delete-git-credentials-secret.yaml
