#!/usr/bin/env bash

# Set variables
#ARTIFACTORY_USER=${ARTIFACTORY_USER:-admin}
#ARTIFACTORY_CURRENT_PASSWORD=${ARTIFACTORY_CURRENT_PASSWORD:-password}

#if [[ -z ${ARTIFACTORY_NEW_PASSWORD} ]]; then
#  echo "Please provide environment variable ARTIFACTORY_NEW_PASSWORD"
#  exit 1
#fi

SEALED_SECRET_NAMESPACE=${SEALED_SECRET_NAMESPACE:-sealed-secrets}
SEALED_SECRET_CONTOLLER_NAME=${SEALED_SECRET_CONTOLLER_NAME:-sealed-secrets}

oc get secret artifactory-access -n tools -o yaml | sed 's/namespace: .*/namespace: ci/' |  oc apply -f - --dry-run=client -o yaml > delete-artifactory-access-secret.yaml

# Change existing password
#oc exec pod/artifactory-artifactory-0 -n tools -it -- curl -XPATCH -uadmin:${ARTIFACTORY_CURRENT_PASSWORD} http://localhost:8040/access/api/v1/users/admin -H 'Content-Type: Application/json' -d '{ "password" : "'"${ARTIFACTORY_NEW_PASSWORD}"'" }' > /dev/null

# Extract encrypted password
#ARTIFACTORY_ENCRYPT=$(oc exec pod/artifactory-artifactory-0 -n tools -it -- curl -X GET -uadmin:"${ARTIFACTORY_NEW_PASSWORD}" http://localhost:8081/artifactory/api/security/encryptedPassword)

# Create Kubernetes Secret yaml
#oc create secret generic artifactory-access \
#--from-literal=ARTIFACTORY_USER=${ARTIFACTORY_USER} \
#--from-literal=ARTIFACTORY_URL='http://artifactory-artifactory.tools:8082' \
#--from-literal=ARTIFACTORY_PASSWORD=${ARTIFACTORY_NEW_PASSWORD} \
#--from-literal=ARTIFACTORY_ENCRYPT=${ARTIFACTORY_ENCRYPT} \
#--dry-run=client -o yaml > delete-artifactory-access-secret.yaml

# Encrypt the secret using kubeseal and private key from the cluster
kubeseal -n ci --controller-name=${SEALED_SECRET_CONTOLLER_NAME} --controller-namespace=${SEALED_SECRET_NAMESPACE} -o yaml < delete-artifactory-access-secret.yaml > artifactory-access-secret.yaml

# NOTE, do not check delete-artifactory-access-secret.yaml into git!
rm delete-artifactory-access-secret.yaml
