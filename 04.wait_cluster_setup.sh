#!/bin/bash

# Colour escape codes
CYAN='\033[1;34m'
GREEN='\033[1;32m'
NC='\033[0m'

VERSION='v2.4.0'

printf "⏳ ${CYAN}Waiting for storageos-api-manager - ${NC}"
until kubectl wait --for=condition=available --timeout=600s deployment/storageos-api-manager -n kube-system >/dev/null 2>&1; do sleep 1; done
echo ✅

printf "⏳ ${CYAN}Waiting for storageos-csi-helper  - ${NC}"
until kubectl wait --for=condition=available --timeout=600s deployment/storageos-csi-helper -n kube-system >/dev/null 2>&1; do sleep 1; done
echo ✅

printf "⏳ ${CYAN}Waiting for storageos-scheduler   - ${NC}"
until kubectl wait --for=condition=available --timeout=600s deployment/storageos-scheduler -n kube-system >/dev/null 2>&1; do sleep 1; done
echo ✅

# https://stackoverflow.com/questions/52532265/is-there-a-way-in-kubernetes-to-wait-on-daemonset-ready
function wait-for-daemonset(){
    retries=10
    while [[ $retries -ge 0 ]];do
        sleep 1
        ready=$(kubectl -n $1 get daemonset $2 -o jsonpath="{.status.numberReady}")
        required=$(kubectl -n $1 get daemonset $2 -o jsonpath="{.status.desiredNumberScheduled}")
        if [[ $ready -eq $required ]];then
            echo ✅
            break
        fi
        ((retries--))
    done
    if [ $retries -eq -1 ]; then echo ❌ - Failed; fi
}

printf "⏳ ${CYAN}Waiting for storageos-daemonset   - ${NC}"
wait-for-daemonset kube-system storageos-daemonset
