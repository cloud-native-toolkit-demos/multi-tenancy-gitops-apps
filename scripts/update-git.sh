#!/usr/bin/env bash

set -eo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR="${SCRIPTDIR}/.."
[[ -n "${DEBUG:-}" ]] && set -x

if [ -z ${GIT_USER} ]; then echo "Please set GIT_USER when running script"; exit 1; fi
set -u

ace_update_git () {
    ACE_GIT_BASEURL=${ACE_GIT_BASEURL:-https://github.com}
    ACE_GITOPS_REPO=${ACE_GITOPS_REPO:-multi-tenancy-gitops-apps.git}
    ACE_GITOPS_BRANCH=${ACE_GITOPS_BRANCH:-ocp47-2021-2}
    ACE_GIT_APP_REPO=${ACE_GIT_APP_REPO:-ace-customer-details.git}

    find ${ROOTDIR}/ace/environments -name '*.yaml' -print0 |
    while IFS= read -r -d '' File; do
        echo "Processing $File"
        sed -i'.bak' -e "s#https://github.com/cloud-native-toolkit-demos/multi-tenancy-gitops-apps.git#${ACE_GIT_BASEURL}/${GIT_USER}/${ACE_GITOPS_REPO}#" $File
        sed -i'.bak' -e "s#https://github.com/cloud-native-toolkit-demos/ace-customer-details.git#${ACE_GIT_BASEURL}/${GIT_USER}/${ACE_GIT_APP_REPO}#" $File
        rm "${File}.bak"
    done

    if [[ -z "${SKIP_ARGO_REPLACE_GIT}" ]]; then
        find ${ROOTDIR}/ace/config/argocd -name '*.yaml' -print0 |
        while IFS= read -r -d '' File; do
            echo "Processing $File"
            sed -i'.bak' -e "s#https://github.com/cloud-native-toolkit-demos/multi-tenancy-gitops-apps.git#${ACE_GIT_BASEURL}/${GIT_USER}/${ACE_GITOPS_REPO}#" $File
            sed -i'.bak' -e "s#targetRevision: master#targetRevision: ${ACE_GITOPS_BRANCH}#" $File
            rm "${File}.bak"
        done
    fi

    echo "git commit and push changes now"
}

ace_review_git () {
    pushd $ROOTDIR/ace
    git diff
    popd
}

ace_git_add_commit_push () {
    pushd $ROOTDIR/ace
    git add .
    git commit -m "update kubseal for ace files"
    git push origin
    popd
}

# main

ace_update_git

ace_review_git

ace_git_add_commit_push