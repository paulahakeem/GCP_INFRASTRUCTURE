resource "google_service_account" "gke_sa" {
  account_id = "gke-cluster-nodes"
  display_name = "GKE Cluster Nodes Service Account"
}

resource "google_project_iam_binding" "gke_sa_binding" {
  project = "paula-terraform"
  role = "roles/storage.objectViewer"
  members = [
    "serviceAccount:${google_service_account.gke_sa.email}"
  ]
}
#----------------------------------------------------------

resource "google_service_account" "vm_sa" {
  account_id = "vmm-saa"
  display_name = "Vm Service Account"
}

resource "google_project_iam_binding" "vm_sa_binding" {
  project = "paula-terraform"
  role = "roles/container.admin"
  members = [
    "serviceAccount:${google_service_account.vm_sa.email}"
  ]
}


