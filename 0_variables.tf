variable "project_id" {
    description = "project id"
    default = ""
  }

  variable "region" {
    description = "Region"
    default = "europe-west1"
  }

  variable "zones" {
    description = "zones to deploy nodes"
    default = ["europe-west1-b", "europe-west1-c"]
  }

  variable "network" {
    description = "Network"
    default = "default"
  }

  variable "subnetwork" {
    description = "Subnet"
    default = "dataprep-subnetwork"
  }

  variable "service_account" {
    description = "Service Account assinged to GKE nodes"
    default = "dataprep-gke-sa"
  }

  variable "cluster" {
    description = "Name of GKE cluster to deploy"
    default = "dataprep-vpc-cluster"
  }

  variable "workspace_ip" {
    description = "ip address of machine running terraform script"
    default = ""
  }