#!/bin/bash
set -e

echo "📥 Generating Ansible inventory from Terraform output..."

cd terraform
terraform output -json > tfout.json
cd ..

# Extract the IPs
IP_LIST=$(jq -r '.instance_ips.value[]?' terraform/tfout.json)

if [[ -z "$IP_LIST" ]]; then
  echo "❌ No instance IPs found. Aborting."
  exit 1
fi

MASTER_IP=$(echo "$IP_LIST" | sed -n 1p)
WORKER_IP1=$(echo "$IP_LIST" | sed -n 2p)


cat <<EOF > ansible/inventory.ini
[masters]
$MASTER_IP ansible_user=ubuntu ansible_host=$MASTER_IP

[workers]
$WORKER_IP1 ansible_user=ubuntu ansible_host=$WORKER_IP1

EOF

echo "✅ Inventory generated at ansible/inventory.ini"
cat ansible/inventory.ini
