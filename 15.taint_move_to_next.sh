#!/bin/bash

# Colour escape codes
CYAN='\033[1;34m'
GREEN='\033[1;32m'
NC='\033[0m'

# Taint node1
for node in $(cat scheduable.txt | sed '2,$d')
do
   kubectl taint nodes ${node} exclusive=true:NoSchedule --overwrite &> /dev/null && echo -e "⚠️  ${GREEN}Tainted ${node} - ${CYAN}kubectl taint nodes ${node} exclusive=true:NoSchedule --overwrite${NC}"
done

# UnTaint node2
for node in $(cat scheduable.txt | sed -n 2p )
do
   kubectl taint nodes ${node} exclusive=true:NoSchedule- --overwrite &> /dev/null; echo -e "✅ ${GREEN}UnTainted ${node} - ${CYAN}kubectl taint nodes ${node} exclusive=true:NoSchedule- --overwrite${NC}"
done

# Taint node 3 onwards
for node in $(cat scheduable.txt | sed '1,2d')
do
   kubectl taint nodes ${node} exclusive=true:NoSchedule --overwrite &> /dev/null && echo -e "⚠️  ${GREEN}Tainted ${node} - ${CYAN}kubectl taint nodes ${node} exclusive=true:NoSchedule --overwrite${NC}"
done
