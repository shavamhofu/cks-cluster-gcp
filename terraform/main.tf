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
      image = "ubuntu-2004-focal-v20220419"
      size  = 50
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    # ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    ssh-keys = "ubuntu:${tls_private_key.vm_ssh.public_key_openssh}"
  }

  tags = ["cks-node"]
}

resource "google_compute_instance" "cks-worker" {
  name         = "cks-worker"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20220419"
      size  = 50
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    # ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    ssh-keys = "ubuntu:${tls_private_key.vm_ssh.public_key_openssh}"
  }

  tags = ["cks-node"]
}

resource "google_compute_firewall" "nodeports" {
  name    = "nodeports"
  network = "default"

#   added port 22 to allow ssh from my local machine

  allow {
    protocol = "tcp"
    ports    = ["30000-40000","22"]
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


