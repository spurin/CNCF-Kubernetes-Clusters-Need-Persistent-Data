#!/bin/bash

# Colour escape codes
CYAN='\033[1;34m'
GREEN='\033[1;32m'
NC='\033[0m'

function wait_termination() {
    printf "\n❌ ${GREEN}Waiting for Terminating items ... "
    sleep 2
    while [ $? -eq 0 ]; do
    kubectl get all -A 2>/dev/null | grep Terminating >/dev/null
    done
    echo -e "${CYAN}done${NC}\n"
}

echo -e "❌ ${GREEN}Removing pod/mysql - ${CYAN}kubectl delete pod/mysql --grace-period=0${NC}"
kubectl delete pod/mysql --grace-period=0 --wait=true
wait_termination

PV=$(kubectl get pvc/mysqlpvc -o jsonpath={'.spec.volumeName'})
echo -e "\n❌ ${GREEN}Removing pvc/mysqlpvc - ${CYAN}kubectl delete pvc/mysqlpvc --wait=true${NC}"
kubectl delete pvc/mysqlpvc --wait=true
wait_termination

echo -e "\n❌ ${GREEN}Removing pv/${PV} - ${CYAN}kubectl delete pv/${PV} --wait=true${NC}"
kubectl delete pv/${PV} --wait=true
wait_termination

echo -e "\n❌ ${GREEN}Removing storageclass/topsecret - ${CYAN}kubectl delete storageclass/topsecret --wait=true${NC}"
kubectl delete storageclass/topsecret --wait=true
wait_termination

for node in $(cat scheduable.txt)
do
   kubectl taint nodes ${node} exclusive=true:NoSchedule- --overwrite &> /dev/null; echo -e "✅ ${GREEN}UnTainted ${node} - ${CYAN}kubectl taint nodes ${node} exclusive=true:NoSchedule- --overwrite${NC}"
done

rm -rf scheduable.txt
