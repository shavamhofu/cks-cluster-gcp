# #!/bin/bash

# MASTER_IP=$(terraform -chdir=terraform output -raw master_ip)
# WORKER_IP=$(terraform -chdir=terraform output -raw worker_ip)

# cat <<EOF > ansible/inventory.ini
# [master]
# $MASTER_IP ansible_user=ubuntu

# [worker]
# $WORKER_IP ansible_user=ubuntu
# EOF

# echo "Inventory generated at ansible/inventory.ini"
#!/bin/bash
# cd terraform
# terraform output -json > tfout.json
# cd ..

# MASTER_IP=$(jq -r '.instance_ips.value[0]' terraform/tfout.json)
# WORKER_IP1=$(jq -r '.instance_ips.value[1]' terraform/tfout.json)
# WORKER_IP2=$(jq -r '.instance_ips.value[2]' terraform/tfout.json)

# cat <<EOF > ansible/inventory.ini
# [masters]
# $MASTER_IP ansible_user=ubuntu ansible_host=$MASTER_IP

# [workers]
# $WORKER_IP1 ansible_user=ubuntu ansible_host=$WORKER_IP1
# $WORKER_IP2 ansible_user=ubuntu ansible_host=$WORKER_IP2
# EOF

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
WORKER_IP2=$(echo "$IP_LIST" | sed -n 3p)

cat <<EOF > ansible/inventory.ini
[masters]
$MASTER_IP ansible_user=ubuntu ansible_host=$MASTER_IP

[workers]
$WORKER_IP1 ansible_user=ubuntu ansible_host=$WORKER_IP1
$WORKER_IP2 ansible_user=ubuntu ansible_host=$WORKER_IP2
EOF

echo "✅ Inventory generated at ansible/inventory.ini"
cat ansible/inventory.ini
