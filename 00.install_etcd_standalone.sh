#!/bin/bash
# StorageOS Self-Evaluation This script will install StorageOS onto a
# Kubernetes cluster
# 
# This script is based on the installation instructions in our self-evaluation
# guide: https://docs.storageos.com/docs/self-eval. Please see that guide for
# more information.
# 
# Expectations:
# - Kubernetes cluster with a minium of 3
#   nodes
# - kubectl in the PATH - kubectl access to this cluster with
#   cluster-admin privileges - export KUBECONFIG as appropriate
# The following variables may be tuned as desired. The defaults should work in
# most environments.
export OPERATOR_VERSION='v2.1.0'
export CLI_VERSION='v2.1.0'
export STOS_VERSION='v2.1.0'
export STORAGEOS_OPERATOR_LABEL='name=storageos-cluster-operator'
export STOS_NAMESPACE='kube-system'
export ETCD_NAMESPACE='storageos-etcd'
export STOS_CLUSTERNAME='self-evaluation'

# Colour escape codes
CYAN='\033[1;34m'
RED='\033[0;31m'
GREEN='\033[1;32m'
NC='\033[0m'

echo -e "✨ ${GREEN}Installing Standalone ETCD${NC}"

# If running in Openshift, an SCC is needed to start Pods
if grep -q "openshift" <(kubectl get node --show-labels); then
    oc adm policy add-scc-to-user anyuid \
    system:serviceaccount:${ETCD_NAMESPACE}:default
    sleep 5
fi
kubectl create namespace ${ETCD_NAMESPACE}
echo -e "${GREEN}✨ Creating etcd ClusterRole and ClusterRoleBinding${NC}"
kubectl -n ${ETCD_NAMESPACE} create -f-<<END
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: etcd-operator
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: etcd-operator
subjects:
- kind: ServiceAccount
  name: default
  namespace: ${ETCD_NAMESPACE}
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: etcd-operator
rules:
- apiGroups:
  - etcd.database.coreos.com
  resources:
  - etcdclusters
  - etcdbackups
  - etcdrestores
  verbs:
  - "*"
- apiGroups:
  - apiextensions.k8s.io
  resources:
  - customresourcedefinitions
  verbs:
  - "*"
- apiGroups:
  - ""
  resources:
  - pods
  - services
  - endpoints
  - persistentvolumeclaims
  - events
  verbs:
  - "*"
- apiGroups:
  - apps
  resources:
  - deployments
  verbs:
  - "*"
# The following permissions can be removed if not using S3 backup and TLS
- apiGroups:
  - ""
  resources:
  - secrets
  verbs:
  - get
---
END

# Create etcd operator Deployment - this will deploy and manage the etcd
# instances
echo -e "${GREEN}✨ Creating etcd operator Deployment${NC}"
kubectl -n ${ETCD_NAMESPACE} create -f-<<END
apiVersion: apps/v1
kind: Deployment
metadata:
  name: etcd-operator
spec:
  replicas: 1
  selector:
    matchLabels:
      name: etcd-operator
  template:
    metadata:
      labels:
        name: etcd-operator
    spec:
      containers:
      - name: etcd-operator
        image: quay.io/coreos/etcd-operator:v0.9.4
        command:
        - etcd-operator
        env:
        - name: MY_POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: MY_POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
END
sleep 5

# Wait for etcd operator to become ready
phase="$(kubectl -n ${ETCD_NAMESPACE} get pod -lname=etcd-operator --no-headers -ocustom-columns=status:.status.phase)"
while ! grep -q "Running" <(echo "${phase}"); do
    sleep 2
    phase="$(kubectl -n ${ETCD_NAMESPACE} get pod -lname=etcd-operator --no-headers -ocustom-columns=status:.status.phase)"
done

# Create etcd CustomResource
# This will install 3 etcd pods into the cluster using ephemeral storage. It
# will also create a service endpoint, by which we can refer to the cluster in
# the installation for StorageOS itself below.
echo -e "${GREEN}✨ Creating etcd cluster in namespace ${ETCD_NAMESPACE}${NC}"
kubectl -n ${ETCD_NAMESPACE} create -f- <<END
apiVersion: "etcd.database.coreos.com/v1beta2"
kind: "EtcdCluster"
metadata:
  name: "storageos-etcd"
spec:
  size: 3
  version: "3.4.9"
  pod:
    etcdEnv:
    - name: ETCD_QUOTA_BACKEND_BYTES
      value: "2589934592"  # ~2 GB
    - name: ETCD_AUTO_COMPACTION_MODE
      value: "revision"
    - name: ETCD_AUTO_COMPACTION_RETENTION
      value: "1000"
#  Modify the following requests and limits if required
#    requests:
#      cpu: 2
#      memory: 4G
#    limits:
#      cpu: 2
#      memory: 4G
    resources:
      requests:
        cpu: 200m
        memory: 300Mi
    securityContext:
      runAsNonRoot: true
      runAsUser: 9000
      fsGroup: 9000
# The following toleration allows us to run on a master node - modify to taste
#  Tolerations example
    tolerations:
    - key: "node-role.kubernetes.io/master"
      operator: "Equal"
      value: ""
      effect: "NoSchedule"
    affinity:
      podAntiAffinity:
        preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 100
          podAffinityTerm:
            labelSelector:
              matchExpressions:
              - key: etcd_cluster
                operator: In
                values:
                - storageos-etcd
            topologyKey: kubernetes.io/hostname
END

until kubectl wait --for=condition=available --timeout=600s deployment/etcd-operator -n storageos-etcd >/dev/null; do echo waiting for etcd-operator; sleep 5; done

echo -e "\n✅ ${GREEN}Use the following endpoint for ETCD access - ${CYAN}storageos-etcd-client.storageos-etcd.svc:2379${NC}\n"
