terraform {
  backend "gcs" {
    bucket  = "kubernetesstate"
    prefix  = "terraform/state"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}


provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_instance" "cks-master" {
  name         = "cks-master"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-noble-amd64-v20250530"
      size  = 50
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    ssh-keys = <<EOT
      ubuntu:${tls_private_key.vm_ssh.public_key_openssh}
      root:${tls_private_key.vm_ssh.public_key_openssh}
    EOT

      startup-script = <<-SCRIPT
    #!/bin/bash

    # Ensure root .ssh exists
    mkdir -p /root/.ssh
    chmod 700 /root/.ssh

    # Pre-populate known_hosts using internal DNS name
    ssh-keyscan -H cks-worker >> /root/.ssh/known_hosts

    # Optional: resolve IP and scan it too (safe fallback)
    worker_ip=$(getent hosts cks-worker | awk '{ print $1 }')
    if [ -n "$worker_ip" ]; then
      ssh-keyscan -H "$worker_ip" >> /root/.ssh/known_hosts
    fi

    chmod 600 /root/.ssh/known_hosts
      SCRIPT
  }

  # metadata = {
  #   # ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  #   ssh-keys = "ubuntu:${tls_private_key.vm_ssh.public_key_openssh}"
  # }

  tags = ["cks-node"]
}

resource "google_compute_instance" "cks-worker" {
  name         = "cks-worker"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-noble-amd64-v20250530"
      size  = 50
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    ssh-keys = <<EOT
      ubuntu:${tls_private_key.vm_ssh.public_key_openssh}
      root:${tls_private_key.vm_ssh.public_key_openssh}
    EOT

    startup-script = <<-SCRIPT
    #!/bin/bash
    # Ensure root has authorized_keys
    mkdir -p /root/.ssh
    echo "${tls_private_key.vm_ssh.public_key_openssh}" >> /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
    chmod 700 /root/.ssh
    # Pre-populate known_hosts
    ssh-keyscan -H cks-worker >> /root/.ssh/known_hosts
    worker_ip=$(getent hosts cks-worker | awk '{ print $1 }')
    if [ -n "$worker_ip" ]; then
      ssh-keyscan -H "$worker_ip" >> /root/.ssh/known_hosts
    fi
    chmod 600 /root/.ssh/known_hosts
    SCRIPT
  }

  # metadata = {
  #   # ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  #   ssh-keys = "ubuntu:${tls_private_key.vm_ssh.public_key_openssh}"
  # }

  tags = ["cks-node"]
}

resource "google_compute_firewall" "allow-node-egress-dns-https" {
  name    = "allow-node-egress-dns-https"
  network = "default"

  direction = "EGRESS"
  priority  = 1000

  allow {
    protocol = "udp"
    ports    = ["53"]
  }
  allow {
    protocol = "tcp"
    ports    = ["53", "443"]
  }

  destination_ranges = ["0.0.0.0/0"]
  target_tags        = ["cks-node"]
}

//allows ssh from each node
resource "google_compute_firewall" "internal-ssh" {
  name    = "cks-internal-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_tags = ["cks-node"]
  target_tags = ["cks-node"]
  direction   = "INGRESS"
  priority    = 1001
}

resource "google_compute_firewall" "nodeports" {
  name    = "nodeports"
  network = "default"

#   added port 22 to allow ssh from my local machine
# 10250 is for celium to all node communication
  allow {
    protocol = "tcp"
    ports    = ["30000-40000","22","6443","10250"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["cks-node"]
}

resource "tls_private_key" "vm_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# outputs.tf
output "public_key_openssh" {
  value = tls_private_key.vm_ssh.public_key_openssh
}

output "private_key_pem" {
  value     = tls_private_key.vm_ssh.private_key_pem
  sensitive = true
}


