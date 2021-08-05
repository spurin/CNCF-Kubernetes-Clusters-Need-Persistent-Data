#!/bin/bash

# Colour escape codes
CYAN='\033[1;34m'
GREEN='\033[1;32m'
NC='\033[0m'

echo -e "🔍 ${GREEN}Checking PV's - ${CYAN}kubectl get pv${NC}"
kubectl get pv

echo -e "\n🔍 ${GREEN}Checking PVC's - ${CYAN}kubectl get pvc${NC}"
kubectl get pvc
