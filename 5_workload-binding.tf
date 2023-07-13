# Workload binding
# This creates a Companion-SA for Dataprep users,
# then assigns the dataprep.serviceAgent role.
# If a custom companion-SA already exists, or different roles are required, 
# please edit accordingly

locals {
  description = "key/value map of project to SA-name"
  companion_sas = {
    "sales-engineering-1379" = "ts-datasa"
    "dataprep-premium-demo" = "bhoang-looker-docs-service-acc"
    }
}

module "companion-workload-identity" {
  for_each =  local.companion_sas
  source              = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  use_existing_gcp_sa = true
  project_id          = each.key
  name                = each.value
  namespace           = "default"
}