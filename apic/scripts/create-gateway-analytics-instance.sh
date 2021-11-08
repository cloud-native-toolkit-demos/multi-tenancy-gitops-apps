#!/usr/bin/env bash

set -eo pipefail

# Get the script directory
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ENVIRONMENT_INSTANCES_DIR="$( cd "${SCRIPTDIR}/../environments/multi-cluster/instances" && pwd )"
CONFIG_INSTANCES_DIR="$( cd "${SCRIPTDIR}/../config/argocd/multi-cluster/instances" && pwd )"
[[ -n "${DEBUG:-}" ]] && set -x

if [ -z ${NAME} ]; then 
  echo "Please provide a name for your IBM API Connect Gateway and Analytics instance"
  exit 1
fi

echo "Creating a new IBM Gateway and Analytics instance called ${NAME}"
echo "The IBM API Gateway and Analytics instance will be under --> ${ENVIRONMENT_INSTANCES_DIR}"
echo "The IBM API Gateway and Analytics instance bootstrap application will be under --> ${CONFIG_INSTANCES_DIR}"

set -u

# Check there is not a cluster with that name already
pushd ${ENVIRONMENT_INSTANCES_DIR} > /dev/null
for directory in `ls -d */`
do
  # Check that the cluster name does not exist alraedy
  if [[ "${directory}" == "${NAME}-gateway-analytics-instance/" ]]; then
    echo "[ERROR] - The name ${NAME} you chose for you new IBM API Connect Gateway and Analytics instance already exists. Please, choose a different name."
    exit 1
  fi
done

popd > /dev/null

# Copy the instance folder
cp -R ${SCRIPTDIR}/../templates/apic-multi-cluster/gateway-analytics-instance ${ENVIRONMENT_INSTANCES_DIR}/${NAME}-gateway-analytics-instance
# Copy the bootstrap file
mkdir ${CONFIG_INSTANCES_DIR}/${NAME}-gateway-analytics-instance
cp ${SCRIPTDIR}/../templates/apic-multi-cluster/gateway-analytics-instance.yaml ${CONFIG_INSTANCES_DIR}/${NAME}-gateway-analytics-instance/${NAME}-gateway-analytics-instance.yaml

# Point to the appropriate instance folder in the bootstrap file
sed -i'.bak' -e "s/template-gateway-analytics-instance/${NAME}-gateway-analytics-instance/" "${CONFIG_INSTANCES_DIR}/${NAME}-gateway-analytics-instance/${NAME}-gateway-analytics-instance.yaml"
rm "${CONFIG_INSTANCES_DIR}/${NAME}-gateway-analytics-instance/${NAME}-gateway-analytics-instance.yaml.bak"

echo "Done"