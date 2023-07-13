# Workload binding
# This creates a Companion-SA for Dataprep users,
# then assigns the dataprep.serviceAgent role.
# If a custom companion-SA already exists, or different roles are required, 
# please edit accordingly

locals {
  description = "set of companion SAs for workload binding"
  companion_sas = [
    "",
    ""
  ]
}

module "companion-workload-identity" {
  for_each =  toset(local.companion_sas)
  source              = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  use_existing_gcp_sa = true
  project_id          = var.project_id
  name                = each.key
  namespace           = "default"
}