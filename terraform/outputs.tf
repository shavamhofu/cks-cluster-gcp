output "master_ip" {
  value = google_compute_instance.cks-master.network_interface[0].access_config[0].nat_ip
}

output "worker_ip" {
  value = google_compute_instance.cks-worker.network_interface[0].access_config[0].nat_ip
}
