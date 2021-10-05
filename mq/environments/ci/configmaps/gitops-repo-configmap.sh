#!/usr/bin/env bash

# Set variables
if [[ -z ${GIT_ORG} ]]; then
  echo "Please provide environment variable GIT_ORG"
  exit 1
fi

GIT_BRANCH=${GIT_BRANCH:-master}

# Create Kubernetes Secret yaml
( echo "cat <<EOF" ; cat gitops-repo-configmap.yaml_template ; echo EOF ) | \
GIT_ORG=${GIT_ORG} \
GIT_BRANCH=${GIT_BRANCH} \
sh > gitops-repo-configmap.yaml