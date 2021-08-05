#!/bin/bash

# Colour escape codes
CYAN='\033[1;34m'
GREEN='\033[1;32m'
NC='\033[0m'

if [ ! -f scheduable.txt ];
then
   kubectl get no -o 'go-template={{range .items}}{{$taints:=""}}{{range .spec.taints}}{{if eq .effect "NoSchedule"}}{{$taints = print $taints .key ","}}{{end}}{{end}}{{if not $taints}}{{.metadata.name}}{{ "\n"}}{{end}}{{end}}' > scheduable.txt
fi

# Untaint node1, taint all others
for node in $(cat scheduable.txt | sed '2,$d')
do
   kubectl taint nodes ${node} exclusive=true:NoSchedule- --overwrite &> /dev/null; echo -e "✅ ${GREEN}UnTainted ${node} - ${CYAN}kubectl taint nodes ${node} exclusive=true:NoSchedule- --overwrite${NC}"
done

for node in $(cat scheduable.txt | sed '1d')
do
   kubectl taint nodes ${node} exclusive=true:NoSchedule --overwrite &> /dev/null && echo -e "⚠️  ${GREEN}Tainted ${node} - ${CYAN}kubectl taint nodes ${node} exclusive=true:NoSchedule --overwrite${NC}"
done
