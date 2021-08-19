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

wait_kubeseal_ready () {
    while ! oc wait pod --timeout=-1s --for=condition=Ready -l '!job-name' -n ${SEALED_SECRET_NAMESPACE} > /dev/null; do sleep 30; done
}

ace_kubeseal_git () {
    pushd $ROOTDIR/ace/environments/ci/secrets
    source git-credentials-secret.sh
    popd
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

wait_kubeseal_ready

ace_kubeseal_git

ace_review_git

ace_git_add_commit_push



