#!/usr/bin/env bash

# Set variables
if [ -z ${GIT_HOST} ]; then echo "Please set GIT_HOST when running script"; exit 1; fi
if [ -z ${GIT_ORG} ]; then echo "Please set GIT_ORG when running script"; exit 1; fi
if [ -z ${GIT_GITOPS_APPLICATIONS} ]; then echo "Please set GIT_GITOPS_APPLICATIONS when running script"; exit 1; fi
if [ -z ${GIT_GITOPS_APPLICATIONS_BRANCH} ]; then echo "Please set GIT_GITOPS_APPLICATIONS_BRANCH when running script"; exit 1; fi
if [ -z ${GIT_USER} ]; then echo "Please set GIT_USER when running script"; exit 1; fi


# Create Kubernetes Secret yaml
cat <<EOF > gitops-repo-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  labels:
    app: multi-tenancy-gitops
    group: pipeline
    type: git
  name: gitops-repo-ace
data:
  branch: ${GIT_GITOPS_APPLICATIONS_BRANCH}
  host: ${GIT_HOST}
  org: ${GIT_ORG}
  owner: ${GIT_USER}
  parentdir: .
  protocol: https
  repo: ${GIT_GITOPS_APPLICATIONS}
  url: https://${GIT_HOST}/${GIT_ORG}/${GIT_GITOPS_APPLICATIONS}.git
EOF
