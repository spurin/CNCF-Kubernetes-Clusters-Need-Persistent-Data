#!/bin/bash

# Colour escape codes
CYAN='\033[1;34m'
GREEN='\033[1;32m'
NC='\033[0m'

read -r -d '' DATA << EOF
CREATE DATABASE shop;
USE shop;
CREATE TABLE FRUIT( ID INT PRIMARY KEY NOT NULL, INVENTORY VARCHAR(25) NOT NULL, QUANTITY INT NOT NULL );
INSERT INTO FRUIT (ID,INVENTORY,QUANTITY) VALUES (1, 'Bananas', 132), (2, 'Apples', 165), (3, 'Oranges', 219);
SELECT * FROM FRUIT;
EOF

echo -e "\n🔍 ${GREEN}Populating MySQL - ${CYAN}kubectl exec -i mysql -- mysql <<< \$DATA${NC}"
echo -e "${GREEN}${DATA}${NC}"
kubectl exec -i mysql -- mysql <<< $DATA
