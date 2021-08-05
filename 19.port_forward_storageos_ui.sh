#!/bin/bash

# Colour escape codes
CYAN='\033[1;34m'
GREEN='\033[1;32m'
NC='\033[0m'

echo -e "✨ ${GREEN}Port Forwarding svc/storageos:5705 via kubectl - ${CYAN}kubectl -n kube-system port-forward --address 0.0.0.0 svc/storageos 5705:k8s-1:5705${NC}"
echo -e "✨ ${GREEN}Access via - http://localhost:5705 - ${CYAN}Press Ctrl-C to exit${NC}"
kubectl -n kube-system port-forward --address 0.0.0.0 svc/storageos 5705:5705
