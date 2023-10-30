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
  project = var.project
  region  = var.region
  zone    = var.zone
}

# Create VPC Network resource
resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}

# Create VM Instance resource
resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "e2-standard-4"
  tags         = ["web", "dev"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }
}

 
