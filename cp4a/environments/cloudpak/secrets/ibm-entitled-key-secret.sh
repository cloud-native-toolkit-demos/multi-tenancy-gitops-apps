#!/usr/bin/env bash

# Set variables
IBM_ENTITLEMENT_KEY=<ENTITLEMENT-KEY>
NAMESPACE=cloudpak
SEALEDSECRET_NAMESPACE=sealed-secrets

# Create Kubernetes Secret yaml
oc create secret docker-registry ibm-entitlement-key \
--docker-username=cp \
--docker-server=cp.icr.io \
--docker-password=${IBM_ENTITLEMENT_KEY} \
--namespace=${NAMESPACE} \
--dry-run=true -o yaml > delete-ibm-entitled-key-secret.yaml

# Encrypt the secret using kubeseal and private key from the cluster
kubeseal -n ${NAMESPACE} --controller-name=sealedsecretcontroller-sealed-secrets --controller-namespace=${SEALEDSECRET_NAMESPACE} -o yaml < delete-ibm-entitled-key-secret.yaml > ibm-entitled-key-secret.yaml

# NOTE, do not check delete-ibm-entitled-key-secret.yaml into git!
rm delete-ibm-entitled-key-secret.yaml