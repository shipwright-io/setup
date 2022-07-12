#!/usr/bin/env bash
#
# Installs Shipwright Build Controller and Build-Strategies using the Makefile target.
#

set -eu -o pipefail

# the install target uses ko to produce a container image out of the go project, ko loads the
# container image directly into KinD (Kubernetes in Docker), however when using an alternative
# cluster name it needs to be declared using KIND_CLUSTER_NAME environment variable
KIND_CLUSTER_NAME="${KIND_CLUSTER_NAME:-}"

source common.sh

readonly REPO_NAME="build"
CLONE_DIR="."

if ! is_current_repo "${REPO_NAME}" ; then
	CLONE_DIR="${GITHUB_WORKSPACE}/src/${REPO_NAME}"
fi

cd "${CLONE_DIR}" || fail "Directory '${CLONE_DIR}' does not exit!"

echo "# Deploying Shipwright Controller (pwd='${CLONE_DIR}', kind='${KIND_CLUSTER_NAME}')..."
make install-controller-kind

echo "# Waiting for Build Controller rollout..."
rollout_status "${SHIPWRIGHT_NAMESPACE}" "shipwright-build-controller"

echo "# Installing upstream Build-Strategies..."
make install-strategies
