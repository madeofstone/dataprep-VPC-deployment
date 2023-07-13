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

# Create Service Account to be attached to gke nodes
# This is not the same SA that will be running the Dataprep pods
data "google_service_account" "dataprep-gke-sa" {
account_id = var.service_account
}

# Get data about network to use.
# Reference network for gke deployment (must already exist)
data "google_compute_network" "dataprep-net" {
  name = var.network
}

# Reference subnet for gke deployment (must already exist)
data "google_compute_subnetwork" "dataprep-subnet" {
  name          = var.subnetwork
  region        = var.region
}

# *Router and Nat must already exist in Network