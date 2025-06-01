#!/bin/bash

MASTER_IP=$(terraform -chdir=terraform output -raw master_ip)
WORKER_IP=$(terraform -chdir=terraform output -raw worker_ip)

cat <<EOF > ansible/inventory.ini
[master]
$MASTER_IP ansible_user=ubuntu

[worker]
$WORKER_IP ansible_user=ubuntu
EOF

echo "Inventory generated at ansible/inventory.ini"
