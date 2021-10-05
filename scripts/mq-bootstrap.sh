#!/usr/bin/env bash

set -eo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR="${SCRIPTDIR}/.."
[[ -n "${DEBUG:-}" ]] && set -x

pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

SEALED_SECRET_NAMESPACE=${SEALED_SECRET_NAMESPACE:-sealed-secrets}

if [ -z ${GIT_USER} ]; then echo "Please set GIT_USER when running script"; exit 1; fi

if [ -z ${GIT_TOKEN} ]; then echo "Please set GIT_TOKEN when running script"; exit 1; fi

if [ -z ${GIT_ORG} ]; then echo "Please set GIT_ORG when running script"; exit 1; fi

#if [ -z ${ARTIFACTORY_NEW_PASSWORD} ]; then echo "Please set ARTIFACTORY_NEW_PASSWORD when running script"; exit 1; fi


wait_kubeseal_ready () {
    while ! oc wait pod --timeout=-1s --for=condition=Ready -l '!job-name' -n ${SEALED_SECRET_NAMESPACE} > /dev/null; do sleep 30; done
}

mq_kubeseal_artifactory () {
    pushd $ROOTDIR/mq/environments/ci/secrets
    source artifactory-access-secret.sh
    popd
}

mq_kubeseal_git () {
    pushd $ROOTDIR/mq/environments/ci/secrets
    source git-credentials-secret.sh
    popd
}

mq_gitops_repo_cm () {
    pushd $ROOTDIR/mq/environments/ci/configmaps
    source gitops-repo-configmap.sh
    popd    
}

kubseal_ibm_entitled_registry () {
    pushd $ROOTDIR/mq/environments/ci/secrets
    source ibm-entitled-registry-credentials-secret.sh
    popd    
}

mq_kubseal_client_jks_pass_ci () {
    pushd $ROOTDIR/mq/environments/ci/secrets
    source mq-client-jks-password-secret.sh
    popd    
}

mq_client_certificate_ci () {
    pushd $ROOTDIR/mq/environments/ci/certificates
    source ci-mq-client-certificate.sh
    popd    
}

mq_server_certificate_ci () {
    pushd $ROOTDIR/mq/environments/ci/certificates
    source ci-mq-server-certificate.sh
    popd    
}

mq_kubseal_client_jks_pass_dev () {
    pushd $ROOTDIR/mq/environments/dev/secrets
    source mq-client-jks-password-secret.sh
    popd    
}

mq_client_certificate_dev () {
    pushd $ROOTDIR/mq/environments/dev/certificates
    source dev-mq-client-certificate.sh
    popd    
}

mq_server_certificate_dev () {
    pushd $ROOTDIR/mq/environments/dev/certificates
    source dev-mq-server-certificate.sh
    popd    
}

mq_kubseal_client_jks_pass_staging () {
    pushd $ROOTDIR/mq/environments/staging/secrets
    source mq-client-jks-password-secret.sh
    popd    
}

mq_client_certificate_staging () {
    pushd $ROOTDIR/mq/environments/staging/certificates
    source staging-mq-client-certificate.sh
    popd    
}

mq_server_certificate_staging () {
    pushd $ROOTDIR/mq/environments/staging/certificates
    source staging-mq-server-certificate.sh
    popd    
}

mq_kubseal_client_jks_pass_prod () {
    pushd $ROOTDIR/mq/environments/prod/secrets
    source mq-client-jks-password-secret.sh
    popd    
}

mq_client_certificate_prod () {
    pushd $ROOTDIR/mq/environments/prod/certificates
    source prod-mq-client-certificate.sh
    popd    
}

mq_server_certificate_prod () {
    pushd $ROOTDIR/mq/environments/prod/certificates
    source prod-mq-server-certificate.sh
    popd    
}

mq_selfsigned_certificate () {
    pushd $ROOTDIR/mq/environments/tools/certificates/mq-selfsigned-certificate
    source mq-self-signed-ca-certificate.sh
    popd    
}

mq_review_git () {
    pushd $ROOTDIR/mq
    git diff
    popd
}

mq_git_add_commit_push () {
    pushd $ROOTDIR/mq
    git add .
    git commit -m "update kubseal for mq files"
    git push origin
    popd
}

# main
wait_kubeseal_ready

# execute scripts in mq/environments/ci 
mq_kubeseal_artifactory
mq_kubeseal_git
mq_gitops_repo_cm

# mq_kubseal_client_jks_pass_ci
# mq_client_certificate_ci
# mq_server_certificate_ci
# kubseal_ibm_entitled_registry

# execute scripts in mq/environments/dev
# mq_kubseal_client_jks_pass_dev
# mq_client_certificate_dev
# mq_server_certificate_dev

# execute scripts in mq/environments/staging
# mq_kubseal_client_jks_pass_staging
# mq_client_certificate_staging
# mq_server_certificate_staging

# execute scripts in mq/environments/prod
# mq_kubseal_client_jks_pass_prod
# mq_client_certificate_prod
# mq_server_certificate_prod

# execute scripts in mq/environments/tools
#mq_selfsigned_certificate

# review and commit
mq_review_git
mq_git_add_commit_push



