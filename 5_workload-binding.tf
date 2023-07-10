# Workload binding
# This creates a Companion-SA for Dataprep users,
# then assigns the dataprep.serviceAgent role.
# If a custom companion-SA already exists, or different roles are required, 
# please edit accordingly

resource "google_service_account" "companion-sa" {
  account_id   = "ts-testing-companion-sa"
  display_name = "testing companion SAs with in-vpc terraform"
}

resource "google_project_iam_member" "companion-sa-role-binding" {
    project = var.project_id
    role = "roles/dataprep.serviceAgent"
    member = "serviceAccount:${google_service_account.companion-sa.email}"
}

module "companion-workload-identity" {
  source              = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  use_existing_gcp_sa = true
  name                = google_service_account.companion-sa.account_id
  project_id          = var.project_id
  namespace           = "default"
  cluster_name        = var.cluster
  # wait for the custom GSA to be created to force module data source read during apply
  depends_on = [google_service_account.companion-sa]
}