provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_instance" "cks_master" {
  name         = "cks-master"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      size  = 50
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  tags = ["cks", "master"]
}

resource "google_compute_instance" "cks_worker" {
  name         = "cks-worker"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      size  = 50
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  tags = ["cks", "worker"]
}

resource "google_compute_firewall" "nodeports" {
  name    = "nodeports"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["30000-40000"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["cks"]
}
