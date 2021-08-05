#!/bin/bash

# Colour escape codes
CYAN='\033[1;34m'
GREEN='\033[1;32m'
NC='\033[0m'

VERSION='v2.4.0'

echo -e "✨ ${GREEN}Configuring StorageOS Cluster - ${CYAN}kubectl apply -f- <<EOF"

read -r -d '' YAML << EOF
apiVersion: "storageos.com/v1"
kind: StorageOSCluster
metadata:
  name: "example-storageos"
  namespace: "storageos-operator"                              # StorageOS Pods are in kube-system by default
spec:
  secretRefName: "storageos-api"                               # Reference from the Secret created in the previous step
  secretRefNamespace: "storageos-operator"                     # Namespace of the Secret
  k8sDistro: "upstream"
  images:
    nodeContainer: "storageos/node:${VERSION}"                     # StorageOS version
  kvBackend:
    address: "storageos-etcd-client.storageos-etcd.svc:2379"   # ETCD endpoint
  resources:
    requests:
      memory: "512Mi"
      cpu: 1
EOF

echo -e "${YAML}\nEOF${NC}"

kubectl apply -f- <<< "$YAML"
