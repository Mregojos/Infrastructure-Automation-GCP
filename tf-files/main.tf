# Provider
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  project = "mattgcpprojects"
  region  = "northamerica-northeast1"
  zone    = "northamerica-northeast1-a"
}

# Create VPC Network resource
resource "google_compute_network" "tf-infra-auto-i-vpc" {
  name = "tf-infra-auto-i-vpc"
  auto_create_subnetworks = false
  mtu = 1460
}

# Create three subnets
resource "google_compute_subnetwork" "us-west1" {
  name          = "tf-infra-auto-i-subnet-us-west1"
  ip_cidr_range = "10.100.0.0/20"
  region        = "us-west1"
  network       = google_compute_network.tf-infra-auto-i-vpc.id
}

resource "google_compute_subnetwork" "us-west2" {
  name          = "tf-infra-auto-i-subnet-us-west2"
  ip_cidr_range = "10.200.0.0/20"
  region        = "us-west2"
  network       = google_compute_network.tf-infra-auto-i-vpc.id
}

resource "google_compute_subnetwork" "us-central1" {
  name          = "tf-infra-auto-i-subnet-us-central1"
  ip_cidr_range = "10.150.0.0/20"
  region        = "us-central1"
  network       = google_compute_network.tf-infra-auto-i-vpc.id
}

resource "google_compute_address" "tf-db-static-ip-address" {
    name = "tf-db-static-ip-address"
}

