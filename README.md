"# cks-cluster-gcp" 
# CKS Kubernetes Cluster Setup on GCP

This repo provisions a CKS-ready Kubernetes cluster on Google Cloud using Terraform and Ansible.

## Prerequisites

- gcloud CLI
- terraform
- ansible
- SSH key configured for GCP (default `ubuntu` user)

## Setup

1. Clone this repo
2. Set your GCP project ID in `terraform/terraform.tfvars`
3. Replace SSH key path in `deploy.sh`
4. Run:
todo to put rewrite the file again
```bash
./deploy.sh
