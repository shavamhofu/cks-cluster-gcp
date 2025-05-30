# #!/bin/bash
# set -e

# PROJECT_ID=$(grep project_id terraform/terraform.tfvars | cut -d '=' -f2 | tr -d ' "')
# ZONE=$(grep zone terraform/variables.tf | cut -d '"' -f2)

# echo "[*] Initializing Terraform..."
# cd terraform
# terraform init
# terraform apply -auto-approve
# cd ..

# echo "[*] Fetching VM external IPs..."
# MASTER_IP=$(gcloud compute instances describe cks-master --zone=$ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)')
# WORKER_IP=$(gcloud compute instances describe cks-worker --zone=$ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

# echo "[*] Generating Ansible inventory..."
# cat <<EOF > ansible/inventory.ini
# [masters]
# cks-master ansible_host=$MASTER_IP

# [workers]
# cks-worker ansible_host=$WORKER_IP

# [all:vars]
# ansible_user=ubuntu
# ansible_ssh_private_key_file=~/.ssh/YOUR_PRIVATE_KEY
# EOF

# echo "[*] Running Ansible Playbook..."
# ansible-playbook -i ansible/inventory.ini ansible/cks_setup.yml
