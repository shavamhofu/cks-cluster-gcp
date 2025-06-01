#!/bin/bash

echo "📥 Generating Ansible inventory from Terraform output..."

MASTER_IP=$(terraform -chdir=terraform output -raw master_ip 2>/dev/null)
WORKER_IPS=$(terraform -chdir=terraform output -json worker_ips 2>/dev/null | jq -r '.[]')

if [[ -z "$MASTER_IP" ]] || [[ -z "$WORKER_IPS" ]]; then
  echo "❌ No instance IPs found. Aborting."
  exit 1
fi

cat > ansible/inventory.ini <<EOF
[masters]
$MASTER_IP ansible_user=ubuntu ansible_host=$MASTER_IP

[workers]
EOF

for ip in $WORKER_IPS; do
  echo "$ip ansible_user=ubuntu ansible_host=$ip" >> ansible/inventory.ini
done

echo "✅ Inventory generated at ansible/inventory.ini"
