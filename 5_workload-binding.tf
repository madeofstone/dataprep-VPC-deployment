# Workload binding
# This creates a Companion-SA for Dataprep users,
# then assigns the dataprep.serviceAgent role.
# If a custom companion-SA already exists, or different roles are required, 
# please edit accordingly

variable "companion-sas" {
  description = "key/value map of project to SA-name"
  type = map(object({
    sales-engineering-1379 = ts-datasa
    dataprep-premium-demo = bhoang-looker-docs-service-acc
  }))
}

module "companion-workload-identity" {
  for_each = var.companion-sas
  source              = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  use_existing_gcp_sa = true
  name                = each.value
  project_id          = each.key
  namespace           = "default"
}