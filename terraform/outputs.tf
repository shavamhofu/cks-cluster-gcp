output "master_ip" {
  value = google_compute_instance.cks-master.network_interface[0].access_config[0].nat_ip
}

output "worker_ip" {
  value = google_compute_instance.cks-worker.network_interface[0].access_config[0].nat_ip
}

output "instance_ips" {
  value = [
    google_compute_instance.cks-master.network_interface[0].access_config[0].nat_ip,
    google_compute_instance.cks-worker[0].network_interface[0].access_config[0].nat_ip,
    # google_compute_instance.worker[1].network_interface[0].access_config[0].nat_ip
  ]
}
