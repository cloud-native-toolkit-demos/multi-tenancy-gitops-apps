#!/usr/bin/env bash

# Set variables
USERNAME=<soapserver username>
PASSWORD=<soapserver password>
CERT_PATH=<CERT-PATH>
SEALEDSECRET_NAMESPACE=sealed-secrets

# Create Kubernetes Secret yaml
oc create secret generic basic-auth-rest \
--from-literal=username=${USERNAME} \
--from-literal=password=${PASSWORD} \
--type Opaque \
--dry-run=true -o yaml > delete-basic-auth-rest-secret.yaml 

oc create secret generic ibm-client-key-certs \
--from-file=ibm-ca.crt=${CERT_PATH}/ibm-ca.crt \
--from-file=ibm-client.crt=${CERT_PATH}/ibm-client.crt \
--from-file=ibm-client.key=${CERT_PATH}/ibm-client.key \
--type Opaque \
--dry-run=true -o yaml > delete-ibm-client-key-certs-secret.yaml


# Encrypt the secret using kubeseal and private key from the cluster
kubeseal --scope cluster-wide --controller-name=sealedsecretcontroller-sealed-secrets --controller-namespace=${SEALEDSECRET_NAMESPACE} -o yaml < delete-basic-auth-rest-secret.yaml > basic-auth-rest-secret.yaml 
kubeseal --scope cluster-wide --controller-name=sealedsecretcontroller-sealed-secrets --controller-namespace=${SEALEDSECRET_NAMESPACE} -o yaml < delete-ibm-client-key-certs-secret.yaml > ibm-client-key-certs-secret.yaml

# NOTE, do not check delete-ibm-entitled-key-secret.yaml into git!
rm delete-basic-auth-rest-secret.yaml 
rm delete-ibm-client-key-certs-secret.yaml