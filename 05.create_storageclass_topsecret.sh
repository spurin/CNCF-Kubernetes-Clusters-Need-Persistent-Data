#!/bin/bash

# Colour escape codes
CYAN='\033[1;34m'
GREEN='\033[1;32m'
NC='\033[0m'

echo -e "✨ ${GREEN}Creating StorageClass topsecret - ${CYAN}kubectl apply -f- <<EOF"

read -r -d '' YAML << EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: topsecret
  labels:
    app: storageos
provisioner: csi.storageos.com # CSI Driver
allowVolumeExpansion: true
parameters:
  storageos.com/replicas: "2" # 3 copies of Data, 1 Primary, 2 Replicas
  storageos.com/encryption: "true" # Enable encryption
  csi.storage.k8s.io/controller-expand-secret-name: csi-controller-expand-secret
  csi.storage.k8s.io/controller-expand-secret-namespace: kube-system
  csi.storage.k8s.io/controller-publish-secret-name: csi-controller-publish-secret
  csi.storage.k8s.io/controller-publish-secret-namespace: kube-system
  csi.storage.k8s.io/fstype: ext4
  csi.storage.k8s.io/node-publish-secret-name: csi-node-publish-secret
  csi.storage.k8s.io/node-publish-secret-namespace: kube-system
  csi.storage.k8s.io/provisioner-secret-name: csi-provisioner-secret
  csi.storage.k8s.io/provisioner-secret-namespace: kube-system
EOF

echo -e "${YAML}\nEOF${NC}"

kubectl apply -f- <<< "$YAML"
