cat > main.tf << EOF
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
  project = "$PROJECT_NAME"
  region  = "northamerica-northeast1"
  zone    = "northamerica-northeast1-a"
}

# Create VPC Network resource
resource "google_compute_network" "$VPC_NAME" {
  name = "$VPC_NAME"
  auto_create_subnetworks = false
  mtu = 1460
}

# Create three subnets
resource "google_compute_subnetwork" "$REGION" {
  name          = "$SUBNET_NAME-$REGION"
  ip_cidr_range = "$RANGE_A"
  region        = "$REGION"
  network       = google_compute_network.$VPC_NAME.id
}

resource "google_compute_subnetwork" "$CLOUD_BUILD_REGION" {
  name          = "$SUBNET_NAME-$CLOUD_BUILD_REGION"
  ip_cidr_range = "$RANGE_B"
  region        = "$CLOUD_BUILD_REGION"
  network       = google_compute_network.$VPC_NAME.id
}

resource "google_compute_subnetwork" "$NOTEBOOK_REGION" {
  name          = "$SUBNET_NAME-$NOTEBOOK_REGION"
  ip_cidr_range = "$RANGE_C"
  region        = "$NOTEBOOK_REGION"
  network       = google_compute_network.$VPC_NAME.id
}

resource "google_compute_address" "$STATIC_IP_ADDRESS_NAME" {
    name = "$STATIC_IP_ADDRESS_NAME"
    region = "$REGION"
}

EOF

sh tf.sh