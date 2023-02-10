resource "google_container_cluster" "GKE" {
  name                     = "primary"
  location                 = "us-central1-a"
  remove_default_node_pool = true
  initial_node_count       = 2
  network                  = google_compute_network.main_vpc.self_link
  subnetwork               = google_compute_subnetwork.restricted-subnet.self_link
  networking_mode          = "VPC_NATIVE"

  # Optional, if you want multi-zonal cluster
  # node_locations = [
  #   "us-central1-b"
  # ]

  ip_allocation_policy {
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  
  master_authorized_networks_config {
      cidr_blocks {
        cidr_block   = "10.0.0.0/16"
        display_name = "managed_subnet"
      }
  }

    master_auth {
      client_certificate_config {
        issue_client_certificate = false
      }
   }

  #   Jenkins use case
  #   master_authorized_networks_config {
  #     cidr_blocks {
  #       cidr_block   = "10.0.0.0/18"
  #       display_name = "private-subnet-w-jenkins"
  #     }
  #   }
}
# // to install plugin to fetsh the cluster "sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin"

resource "google_container_node_pool" "general" {
  name       = "general"
  cluster    = google_container_cluster.GKE.id
  node_count = 1

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    preemptible  = true
    machine_type = "e2-medium"

    labels = {
      role = "general"
    }

    service_account = google_service_account.gke_sa.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

resource "google_container_node_pool" "spot" {
  name    = "spot"
  cluster = google_container_cluster.GKE.id

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  autoscaling {
    min_node_count = 0
    max_node_count = 10
  }

  node_config {
    preemptible  = true
    machine_type = "e2-medium"

    labels = {
      team = "devops"
    }

    taint {
      key    = "instance_type"
      value  = "spot"
      effect = "NO_SCHEDULE"
    }

    service_account = google_service_account.gke_sa.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}
