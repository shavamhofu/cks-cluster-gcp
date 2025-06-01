#!/bin/bash

echo "📥 Generating Ansible inventory from Terraform output..."

MASTER_IP=$(terraform -chdir=terraform output -raw master_ip 2>/dev/null)
WORKER_IP=$(terraform -chdir=terraform output -raw worker_ip 2>/dev/null)

if [[ -z "$MASTER_IP" ]] || [[ -z "$WORKER_IP" ]]; then
  echo "❌ No instance IPs found. Aborting."
  exit 1
fi

cat > ansible/inventory.ini <<EOF
[masters]
$MASTER_IP ansible_user=ubuntu ansible_host=$MASTER_IP ansible_ssh_private_key_file=~/.ssh/id_rsa

[workers]
$WORKER_IP ansible_user=ubuntu ansible_host=$WORKER_IP ansible_ssh_private_key_file=~/.ssh/id_rsa
EOF

echo "✅ Inventory generated at ansible/inventory.ini"
cat ansible/inventory.ini
