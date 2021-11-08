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

echo "Creating the IBM API Connect component instances under ${ENVIRONMENT_INSTANCES_DIR}"
echo "Creating the IBM API Connect component instances bootstrap applications under --> ${CONFIG_INSTANCES_DIR}"
echo "The IBM Gateway and Analytics instance name is ${NAME}"

set -u

# Copy the management and portal instance
cp -R ${SCRIPTDIR}/../templates/apic-multi-cluster/management-portal-instance ${ENVIRONMENT_INSTANCES_DIR}/management-portal-instance
# Copy the management and portal instance bootstrap application
mkdir ${CONFIG_INSTANCES_DIR}/management-portal-instance
cp ${SCRIPTDIR}/../templates/apic-multi-cluster/management-portal-instance.yaml ${CONFIG_INSTANCES_DIR}/management-portal-instance/management-portal-instance.yaml


# Copy the gateway and analytics instance folder
cp -R ${SCRIPTDIR}/../templates/apic-multi-cluster/gateway-analytics-instance ${ENVIRONMENT_INSTANCES_DIR}/${NAME}-gateway-analytics-instance
# Copy the bootstrap file
mkdir ${CONFIG_INSTANCES_DIR}/${NAME}-gateway-analytics-instance
cp ${SCRIPTDIR}/../templates/apic-multi-cluster/gateway-analytics-instance.yaml ${CONFIG_INSTANCES_DIR}/${NAME}-gateway-analytics-instance/${NAME}-gateway-analytics-instance.yaml

# Point to the appropriate instance folder in the bootstrap file
sed -i'.bak' -e "s/template-gateway-analytics-instance/${NAME}-gateway-analytics-instance/" "${CONFIG_INSTANCES_DIR}/${NAME}-gateway-analytics-instance/${NAME}-gateway-analytics-instance.yaml"
rm "${CONFIG_INSTANCES_DIR}/${NAME}-gateway-analytics-instance/${NAME}-gateway-analytics-instance.yaml.bak"

echo "Done"