# Define required providers
terraform {
  required_providers {
    google = {
        source = "hashicorp/google"
        version = "4.68.0"
    }
    
     kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }
  }
    required_version = ">= 0.14"
  }
    
  provider "google" {
    project = var.project_id
    region = var.region
  }

# Get data about network to use.
# *This could be changed to create a dedicated network if desired
data "google_compute_network" "trifacta-in-vpc-net" {
  name = var.network
}

# make sure the following apis are enabled on project
resource "google_project_service" "compute" {
service = "compute.googleapis.com"
}

resource "google_project_service" "container" {
service = "container.googleapis.com"
}

# Create Service Account to be attached to gke nodes
# This is not the same SA that will be running the Dataprep pods
resource "google_service_account" "dataprep-gke-sa" {
account_id = var.service_account
display_name = "Dataprep GKE node SA"
}

# Assign required roles to node SA
resource "google_project_iam_member" "logging" {
project = var.project_id
role = "roles/logging.logWriter"
member = "serviceAccount:${google_service_account.dataprep-gke-sa.email}"

} 

resource "google_project_iam_member" "monitoring" {
  project = var.project_id
  role = "roles/monitoring.metricWriter"
  member = "serviceAccount:${google_service_account.dataprep-gke-sa.email}"
}

resource "google_project_iam_member" "viewer" {
  project = var.project_id
  role = "roles/monitoring.viewer"
  member = "serviceAccount:${google_service_account.dataprep-gke-sa.email}"
}

resource "google_project_iam_member" "stackdriver" {
  project = var.project_id
  role = "roles/stackdriver.resourceMetadata.writer"
  member = "serviceAccount:${google_service_account.dataprep-gke-sa.email}"
}

resource "google_project_iam_member" "artifactregistry" {
  project = var.project_id
  role = "roles/artifactregistry.reader"
  member = "serviceAccount:${google_service_account.dataprep-gke-sa.email}"
}

# Create subnet with allocated ranges
resource "google_compute_subnetwork" "dataprep-subnet" {
  name          = var.subnetwork
  ip_cidr_range = "10.1.0.0/16"
  region        = var.region
  network       = data.google_compute_network.trifacta-in-vpc-net.id
  secondary_ip_range {
      range_name    = "pod-range"
      ip_cidr_range = "192.168.0.0/17"
  }
  secondary_ip_range {
      range_name    = "services-range"
      ip_cidr_range = "192.168.128.0/22"
  } 
}


# Create the router
resource "google_compute_router" "cloud_router" {
  name = "${var.project_id}-${var.network}-router"
  network = data.google_compute_network.trifacta-in-vpc-net.id
  region = var.region
}

# Create the NAT gateway
resource "google_compute_router_nat" "cloud_nat" {
  name = "${var.project_id}-${var.subnetwork}-nat"
  router = google_compute_router.cloud_router.name
  region = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
      name                    = google_compute_subnetwork.dataprep-subnet.id
      source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
  
  log_config {
  enable = true
  filter = "ERRORS_ONLY"
  }
}