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
    region = "us-west1"
}

resource "google_storage_bucket" "tf-infra-auto-i-startup-script" {
    name = "tf-infra-auto-i-startup-script"
    location = "US"
    force_destroy = true
}

resource "google_storage_bucket_object" "startup-script-object" {
    name = "startup-script"
    source = "app/startup-script.sh"
    bucket = "tf-infra-auto-i-startup-script"
}

resource "google_service_account" "tf-startup-script-bucket-sa" {
    account_id = "tf-startup-script-bucket-sa"
    display_name = "tf-startup-script-bucket-sa"
}

resource "google_project_iam_custom_role" "BUCKET_CUSTOM_ROLE" {
    role_id = "tfbucketCustomRole.i"
    title = "tfbucketCustomRole.i"
    description = "Get the object only"
    permissions = ["storage.objects.get"]
}

resource "google_project_iam_binding" "BUCKET_BINDING" {
    project = "mattgcpprojects"
    role = "projects/mattgcpprojects/roles/tfbucketCustomRole.i"
    members = [
        "serviceAccount:tf-startup-script-bucket-sa@mattgcpprojects.iam.gserviceaccount.com"
        ]
}

resource "google_compute_instance" "tf-infra-auto-i-db" {
    name = "tf-infra-auto-i-db"
    machine_type = "e2-micro"
    zone = "us-west1-a"
    tags = ["db"]
    boot_disk {
        initialize_params {
        image = "debian-cloud/debian-11"
        }
    }
    network_interface {
        network = "tf-infra-auto-i-vpc"
        subnetwork = "tf-infra-auto-i-subnet-us-west1"
        access_config {
            nat_ip = "35.247.48.187"
        }
    }
    metadata_startup_script = "starrtup-script.txt"
    service_account {
        email = "tf-startup-script-bucket-sa@mattgcpprojects.iam.gserviceaccount.com"
        scopes = ["cloud-platform"]
    }
    
}

resource "google_artifact_registry_repository" "tf-infra-auto-i-artifact-registry" {
    location = "us-west1"
    repository_id = "tf-infra-auto-i-artifact-registry"
    description = "Docker repository"
    format = "DOCKER"
}

resource "google_service_account" "tf-app-service-account" {
    account_id = "tf-app-service-account"
    display_name = "tf-app-service-account"
}

resource "google_project_iam_custom_role" "APP_CUSTOM_ROLE" {
    role_id = "tfappCustomRole.i"
    title = "tfappCustomRole.i"
    description = "Predict Only"
    permissions = ["aiplatform.endpoints.predict"]
}

resource "google_project_iam_binding" "APP_BINDING" {
    project = "mattgcpprojects"
    role = "projects/mattgcpprojects/roles/tfappCustomRole.i"
    members = [
        "serviceAccount:tf-app-service-account@mattgcpprojects.iam.gserviceaccount.com"
        ]
}

