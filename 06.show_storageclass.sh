#!/bin/bash

# Colour escape codes
CYAN='\033[1;34m'
GREEN='\033[1;32m'
NC='\033[0m'

echo -e "🔍 ${GREEN}Checking StorageClasses - ${CYAN}kubectl get storageclass${NC}"
kubectl get storageclass
