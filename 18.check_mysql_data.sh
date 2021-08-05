#!/bin/bash

# Colour escape codes
CYAN='\033[1;34m'
GREEN='\033[1;32m'
NC='\033[0m'

echo -e "\n🔍 ${GREEN}Checking MySQL Data - ${CYAN}kubectl exec mysql -- /bin/sh -c \\\"mysql -e \\\"RESET QUERY CACHE; SELECT * FROM shop.FRUIT\\\"\"${NC}"
kubectl exec mysql -- /bin/sh -c "mysql -e \"SELECT * from shop.FRUIT\""
