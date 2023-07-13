variable "project_id" {
    description = "project id to deploy gke cluster"
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

variable "subnet" {
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

variable "photon-node-size" {
  description = "machine size for Photon node pool"
  default = "e2-standard-8"
}

variable "data-service-node-size" {
  description = "machine size for Photon node pool"
  default = "e2-standard-4"
}

variable "convert-node-size" {
  description = "machine size for Photon node pool"
  default = "e2-standard-2"
}

variable "workspace_ip" {
  description = "ip address of machine running terraform script (include /32)"
  default = ""
}