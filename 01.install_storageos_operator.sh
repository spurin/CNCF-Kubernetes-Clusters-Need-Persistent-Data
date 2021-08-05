#!/bin/bash

# See https://github.com/storageos/cluster-operator/tags for the version, change accordingly as required
VERSION=v2.4.0

# Colour escape codes
CYAN='\033[1;34m'
GREEN='\033[1;32m'
NC='\033[0m'

echo -e "✨ ${GREEN}Installing the StorageOS Operator - ${CYAN}kubectl create -f https://github.com/storageos/cluster-operator/releases/download/${VERSION}/storageos-operator.yaml${NC}"
kubectl create -f https://github.com/storageos/cluster-operator/releases/download/${VERSION}/storageos-operator.yaml

until kubectl wait --for=condition=available --timeout=600s deployment/storageos-cluster-operator -n storageos-operator >/dev/null; do echo -e "⌛ ${CYAN}waiting for storageos-cluster-operator${NC}"; sleep 5; done
