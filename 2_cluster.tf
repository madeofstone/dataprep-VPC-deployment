# Get data for kubernetes access
data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

# Build gke cluster via private-cluster gke module provided by Google
module "gke" {
  source                      = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  project_id                  = var.project_id
  name                        = var.cluster
  regional                    = false
  region                      = var.region
  zones                       = var.zones
  network                     = var.network
  subnetwork                  = google_compute_subnetwork.dataprep-subnet.name
  create_service_account      = false
  service_account             = google_service_account.dataprep-gke-sa.email
  enable_binary_authorization = true
  release_channel             = "UNSPECIFIED"
  node_metadata               = "GKE_METADATA"
  enable_private_nodes        = true
  enable_shielded_nodes       = true
  default_max_pods_per_node   = 110
  remove_default_node_pool    = true
  disable_legacy_metadata_endpoints = true
  logging_enabled_components        = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  monitoring_enabled_components     = ["SYSTEM_COMPONENTS"]
  horizontal_pod_autoscaling = true
  http_load_balancing        = true
  gce_pd_csi_driver          = true
  ip_range_services          = "services-range"
  ip_range_pods              = "pod-range"
  master_ipv4_cidr_block     = "10.1.0.0/28"

  node_pools = [
    {
      name              = "photon-job-pool"
      min_count         = 1
      max_count         = 10
      max_surge         = 1
      max_unavailable   = 0
      disk_size_gb      = 100
      disk_type         = "pd-standard"
      autoscaling       = true
      auto_repair       = true
      auto_upgrade      = false
      service_account   = google_service_account.dataprep-gke-sa.email
      preemptible       = false
      image_type        = "COS_CONTAINERD"
      machine_type      = "n1-standard-16"
      version           = "1.27.2-gke.2100"
      enable_integrity_monitoring = true
      enable_secure_boot          = true
    },
    {
      name              = "data-system-job-pool"
      min_count         = 1
      max_count         = 10
      max_surge         = 1
      max_unavailable   = 0
      disk_size_gb      = 100
      disk_type         = "pd-standard"
      autoscaling       = true
      auto_repair       = true
      auto_upgrade      = false
      service_account   = google_service_account.dataprep-gke-sa.email
      preemptible       = false
      image_type        = "COS_CONTAINERD"
      machine_type      = "n1-standard-16"
      version           = "1.22.7-gke.1300"
      enable_integrity_monitoring = true
      enable_secure_boot          = true
    },
    {
      name              = "convert-job-pool"
      min_count         = 1
      max_count         = 10
      max_surge         = 1
      max_unavailable   = 0
      disk_size_gb      = 100
      disk_type         = "pd-standard"
      autoscaling       = true
      auto_repair       = true
      auto_upgrade      = false
      service_account   = google_service_account.dataprep-gke-sa.email
      preemptible       = false
      image_type        = "COS_CONTAINERD"
      machine_type      = "n1-standard-16"
      version           = "1.22.7-gke.1300"
      enable_integrity_monitoring = true
      enable_secure_boot          = true
    }
  ]

  node_pools_taints = {
    all = []

    photon-job-pool = [
      {
        key    = "jobType"
        value  = "photon"
        effect = "NO_SCHEDULE"
      }
    ],
    data-system-job-pool = [
      {
        key    = "jobType"
        value  = "dataSystem"
        effect = "NO_SCHEDULE"
      }
    ],
  }

  master_authorized_networks = [
    {
      cidr_block   = "34.68.114.64/28"
      display_name = "dataprepService"
    },
    {
      cidr_block   = var.workspace_ip
      display_name = "workspace"
    },
  ]
}

/*
# Create k8s namespaces (if required)
resource "kubernetes_namespace" "photon" {
  metadata {
    name = "photon-job-namespace"
  }
}

resource "kubernetes_namespace" "data-system" {
  metadata {
    name = "data-system-job-namespace"
  }
}

resource "kubernetes_namespace" "convert" {
  metadata {
    name = "convert-job-namespace"
  }
}
*/

# Output cluster ca-cert
output "ca_cert_base64" {
  value = module.gke.ca_certificate
  sensitive = true
}

output "ca_cert_decoded" {
  value = base64decode(module.gke.ca_certificate)
  sensitive = true
}

output "gke_endpoint" {
  value = module.gke.endpoint
  sensitive = true
}
