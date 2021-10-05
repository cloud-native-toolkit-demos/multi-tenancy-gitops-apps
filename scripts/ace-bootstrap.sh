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


if [ -z ${GIT_USER} ]; then echo "Please set GIT_USER when running script"; exit 1; fi

if [ -z ${GIT_TOKEN} ]; then echo "Please set GIT_TOKEN when running script"; exit 1; fi

if [ -z ${GIT_ORG} ]; then echo "Please set GIT_ORG when running script"; exit 1; fi

SKIP_ARGO_REPLACE_GIT=${SKIP_ARGO_REPLACE_GIT:-true}
SEALED_SECRET_NAMESPACE=${SEALED_SECRET_NAMESPACE:-sealed-secrets}
GIT_HOST=${GIT_HOST:-github.com}
GIT_BASEURL=${GIT_BASEURL-https://${GIT_HOST}}
GIT_GITOPS_APPLICATIONS=${GIT_GITOPS_APPLICATIONS:-multi-tenancy-gitops-apps}
GIT_GITOPS_APPLICATIONS_BRANCH=${GIT_GITOPS_APPLICATIONS_BRANCH:-master}
GIT_ACE_APP=${GIT_ACE_APP:-ace-customer-details}


wait_kubeseal_ready () {
    while ! oc wait pod --timeout=-1s --for=condition=Ready -l '!job-name' -n ${SEALED_SECRET_NAMESPACE} > /dev/null; do sleep 30; done
}

ace_git_pull () {
    pushd $ROOTDIR
    git pull
    popd
}
ace_kubeseal_git () {
    pushd $ROOTDIR/ace/environments/ci/secrets
    source git-credentials-secret.sh
    popd
}

ace_gitops_repo_cm () {
    pushd $ROOTDIR/ace/environments/ci/configmaps
    source gitops-repo-configmap.sh
    popd
}

ace_update_git () {

    find ${ROOTDIR}/ace/environments -name '*.yaml' -print0 |
    while IFS= read -r -d '' File; do
        echo "Processing $File"
        sed -i'.bak' -e "s#https://github.com/cloud-native-toolkit-demos/multi-tenancy-gitops-apps.git#${GIT_BASEURL}/${GIT_ORG}/${GIT_GITOPS_APPLICATIONS}#" $File
        sed -i'.bak' -e "s#https://github.com/cloud-native-toolkit-demos/ace-customer-details.git#${GIT_BASEURL}/${GIT_ORG}/${GIT_ACE_APP}#" $File
        rm "${File}.bak"
    done

    if [[ "${SKIP_ARGO_REPLACE_GIT}" == "false" ]]; then
        find ${ROOTDIR}/ace/config/argocd -name '*.yaml' -print0 |
        while IFS= read -r -d '' File; do
            echo "Processing $File"
            sed -i'.bak' -e "s#https://github.com/cloud-native-toolkit-demos/multi-tenancy-gitops-apps.git#${GIT_BASEURL}/${GIT_ORG}/${GIT_GITOPS_APPLICATIONS}#" $File
            sed -i'.bak' -e "s#targetRevision: master#targetRevision: ${GIT_GITOPS_APPLICATIONS_BRANCH}#" $File
            rm "${File}.bak"
        done
    fi

}

ace_review_git () {
    pushd $ROOTDIR/ace
    git --no-pager diff
    popd
}

ace_git_add_commit_push () {
    pushd $ROOTDIR/ace
    git add .
    git commit -m "update for ace files"
    git push origin
    popd
}

# main

wait_kubeseal_ready

ace_git_pull

ace_kubeseal_git

ace_gitops_repo_cm

ace_update_git

ace_review_git

ace_git_add_commit_push



