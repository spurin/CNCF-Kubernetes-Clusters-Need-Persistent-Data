#!/bin/bash

# Colour escape codes
CYAN='\033[1;34m'
GREEN='\033[1;32m'
NC='\033[0m'

echo -e "✨ ${GREEN}Creating MySQL Pod - ${CYAN}kubectl apply -f- <<EOF"

read -r -d '' YAML << EOF
apiVersion: v1
kind: Pod
metadata:
  labels:
    name: mysql
  name: mysql
spec:
  containers:
    - name: mysql
      image: mysql:5.7
      env:
      - name: MYSQL_ALLOW_EMPTY_PASSWORD
        value: "1"
      ports:
      - name: mysql
        containerPort: 3306
      volumeMounts:
        - name: mysql-data
          mountPath: /var/lib/mysql
          subPath: mysql
  volumes:
    - name: mysql-data
      persistentVolumeClaim:
        claimName: mysqlpvc
EOF

echo -e "${YAML}\nEOF${NC}"

kubectl apply -f- <<< "$YAML"
