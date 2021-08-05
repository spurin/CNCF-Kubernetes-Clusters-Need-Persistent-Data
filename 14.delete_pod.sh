#!/bin/bash

# Colour escape codes
CYAN='\033[1;34m'
GREEN='\033[1;32m'
NC='\033[0m'

echo -e "❌ ${GREEN}Removing pod/mysql - ${CYAN}kubectl delete pod/mysql --grace-period=0${NC}"
kubectl delete pod/mysql --grace-period=0
