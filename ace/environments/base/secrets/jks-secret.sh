#!/usr/bin/env bash

# Set variables
CERT_PATH=<CERT-PATH>
SEALEDSECRET_NAMESPACE=sealed-secrets

# Create Kubernetes Secret yaml
oc create secret generic ibm-ace-server.jks \
--from-file=configuration=${CERT_PATH}/ibm-ace-server.jks \
--type Opaque \
--dry-run=true -o yaml > delete-ibm-ace-server-jks-secret.yaml

oc create secret generic ibm-ca.jks \
--from-file=configuration=${CERT_PATH}/ibm-ca.jks \
--type Opaque \
--dry-run=true -o yaml > delete-ibm-ca-jks-secret.yaml


# Encrypt the secret using kubeseal and private key from the cluster
kubeseal --scope cluster-wide --controller-name=sealedsecretcontroller-sealed-secrets --controller-namespace=${SEALEDSECRET_NAMESPACE} -o yaml < delete-ibm-ace-server-jks-secret.yaml > ibm-ace-server-jks-secret.yaml
kubeseal --scope cluster-wide --controller-name=sealedsecretcontroller-sealed-secrets --controller-namespace=${SEALEDSECRET_NAMESPACE} -o yaml < delete-ibm-ca-jks-secret.yaml > ibm-ca-jks-secret.yaml

# NOTE, do not check delete-ibm-entitled-key-secret.yaml into git!
rm delete-ibm-ace-server-jks-secret.yaml
rm delete-ibm-ca-jks-secret.yaml