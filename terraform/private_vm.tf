resource "google_compute_instance" "private-vm" {
  name         = "paula-vm"
  machine_type = "e2-medium"
  zone         = "us-central1-a"
  tags         = ["bastion"]
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
        my_label = "value"
      }
    }
  }

  network_interface {
    network = google_compute_network.main_vpc.self_link
    subnetwork = google_compute_subnetwork.managed_subnet.self_link
  }
  service_account {
    email  = google_service_account.vm_sa.email
    scopes = ["cloud-platform"]
  }
}