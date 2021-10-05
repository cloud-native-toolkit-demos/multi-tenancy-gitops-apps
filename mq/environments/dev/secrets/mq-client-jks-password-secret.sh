#!/usr/bin/env bash

# Set variables
KEY_STORE_PASSWORD=${KEY_STORE_PASSWORD:-mqclientdev}
SEALED_SECRET_NAMESPACE=${SEALED_SECRET_NAMESPACE:-sealed-secrets}
SEALED_SECRET_CONTOLLER_NAME=${SEALED_SECRET_CONTOLLER_NAME:-sealed-secrets}

# Create Kubernetes Secret yaml
oc create secret generic mq-client-jks-password \
--from-literal=KEY_STORE_PASSWORD=${KEY_STORE_PASSWORD} \
--dry-run=client -o yaml > delete-mq-client-jks-password-secret.yaml

# Encrypt the secret using kubeseal and private key from the cluster
kubeseal -n dev --controller-name=${SEALED_SECRET_CONTOLLER_NAME} --controller-namespace=${SEALED_SECRET_NAMESPACE} -o yaml < delete-mq-client-jks-password-secret.yaml > mq-client-jks-password-secret.yaml

# NOTE, do not check delete-mq-client-jks-password-secret.yaml into git!
rm delete-mq-client-jks-password-secret.yaml
