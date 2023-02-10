#______________VPC______________
resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
  # disable_dependent_services=true
}

resource "google_project_service" "container" {
  service = "container.googleapis.com"
  # disable_dependent_services=true
}

resource "google_compute_network" "main_vpc" {
  name                            = "main-vpc"
  routing_mode                    = "REGIONAL"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = false

  depends_on = [
    google_project_service.compute,
    google_project_service.container
  ]
}
#______________SUBNETS______________
resource "google_compute_subnetwork" "managed_subnet" {
  name                     = "management-subnet"
  ip_cidr_range            = "10.0.0.0/16"
  region                   = "us-central1"
  network                  = google_compute_network.main_vpc.id
  private_ip_google_access = true

  #   secondary_ip_range {
  #     range_name    = "k8s-pod-range"
  #     ip_cidr_range = "10.48.0.0/14"
  #   }
  #   secondary_ip_range {
  #     range_name    = "k8s-service-range"
  #     ip_cidr_range = "10.52.0.0/20"
  #   }
}



resource "google_compute_subnetwork" "restricted-subnet" {
  name                     = "restricted-subnet"
  ip_cidr_range            = "10.1.0.0/16"
  region                   = "us-central1"
  network                  = google_compute_network.main_vpc.id
  private_ip_google_access = true

  # secondary_ip_range {
  #   range_name    = "k8s-pod-range"
  #   ip_cidr_range = "10.48.0.0/14"
  # }
  # secondary_ip_range {
  #   range_name    = "k8s-service-range"
  #   ip_cidr_range = "10.52.0.0/20"
  # }
}
#______________route______________
resource "google_compute_router" "router" {
  name    = "route-for-managment-subnet"
  region  = google_compute_subnetwork.managed_subnet.region
  network = google_compute_network.main_vpc.id
}
#______________NAT_GATEWAY______________
resource "google_compute_router_nat" "NGW" {
  name   = "nat"
  router = google_compute_router.router.name
  region = "us-central1"

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  nat_ip_allocate_option             = "MANUAL_ONLY"

  subnetwork {
    name                    = google_compute_subnetwork.managed_subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  nat_ips = [google_compute_address.NGW.self_link]
}

resource "google_compute_address" "NGW" {
  name         = "nat"
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"

  depends_on = [google_project_service.compute]
}
#______________FIREWALLS______________
resource "google_compute_firewall" "allow-ssh" {
  name    = "allow-ssh"
  network = google_compute_network.main_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}
