#!/bin/bash

# Colour escape codes
CYAN='\033[1;34m'
GREEN='\033[1;32m'
NC='\033[0m'

echo -e "✨ ${GREEN}Creating MySQL StorageOS Persistent Volume Claim and Persistent Volume - ${CYAN}kubectl apply -f- <<EOF"

read -r -d '' YAML << EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysqlpvc
spec:
  storageClassName: topsecret # 2 replicas + encrypted
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
EOF

echo -e "${YAML}\nEOF${NC}"

kubectl apply -f- <<< "$YAML"
