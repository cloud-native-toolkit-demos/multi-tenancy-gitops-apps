#!/usr/bin/env bash

# Set variables
IBM_REST_DBPARMS_PATH=<IBM-REST-DBPARMS-PATH>
SEALEDSECRET_NAMESPACE=sealed-secrets

# Create Kubernetes Secret yaml
oc create secret generic ibm-rest-dbparms.txt \
--from-file=configuration=${IBM_REST_DBPARMS_PATH}/ibm-rest-dbparms.txt \
--type Opaque \
--dry-run=true -o yaml > delete-ibm-rest-dbparms-secret.yaml

# Encrypt the secret using kubeseal and private key from the cluster
kubeseal --scope cluster-wide --controller-name=sealedsecretcontroller-sealed-secrets --controller-namespace=${SEALEDSECRET_NAMESPACE} -o yaml < delete-ibm-rest-dbparms-secret.yaml > ibm-rest-dbparms-secret.yaml

# NOTE, do not check delete-*-secret.yaml into git!
rm delete-ibm-rest-dbparms-secret.yaml
