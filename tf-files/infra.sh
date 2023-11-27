#---------Application Name Environment Variables----------#
VERSION="i"
APP_NAME="tf-infra-auto-$VERSION"

#---------Project Environment Variables---------#
PROJECT_NAME="$(gcloud config get project)"

#----------Database Instance Environment Variables----------#
VPC_NAME="$APP_NAME-vpc"
SUBNET_NAME="$APP_NAME-subnet"
RANGE_A='10.100.0.0/20'
RANGE_B='10.200.0.0/20'
DB_INSTANCE_NAME="$APP_NAME-db"
MACHINE_TYPE="e2-micro"
REGION="us-west1"
ZONE="us-west1-a"
BOOT_DISK_SIZE="30"
TAGS="db"
FIREWALL_RULES_NAME="$APP_NAME-ports"
STATIC_IP_ADDRESS_NAME="tf-db-static-ip-address"
BUCKET_NAME="$APP_NAME-startup-script"
STARTUP_SCRIPT_BUCKET_SA="tf-startup-script-bucket-sa"
STARTUP_SCRIPT_BUCKET_CUSTOM_ROLE="tfbucketCustomRole.$VERSION"
# STARTUP_SCRIPT_NAME="$APP_NAME-startup-script.sh"

# For Notebook 
NOTEBOOK_REGION='us-central1'
RANGE_C='10.150.0.0/20'

#---------Database Credentials----------#
DB_CONTAINER_NAME="$APP_NAME-postgres-sql"
DB_NAME="$APP_NAME-admin"
DB_USER="$APP_NAME-admin" 
# DB_HOST=$(gcloud compute addresses describe $STATIC_IP_ADDRESS_NAME --region $REGION | grep "address: " | cut -d " " -f2)
DB_HOST=$(gcloud compute instances list --filter="name=$DB_INSTANCE_NAME" --format="value(networkInterfaces[0].accessConfigs[0].natIP)") 
DB_PORT=5000
DB_PASSWORD=$APP_NAME 
PROJECT_NAME="$(gcloud config get project)"
ADMIN_PASSWORD=$APP_NAME 
APP_PORT=9000
APP_ADDRESS=""
DOMAIN_NAME=""
SPECIAL_NAME=$APP_NAME 

#----------Deployment Environment Variables----------#
CLOUD_BUILD_REGION="us-west2"
REGION="us-west1"
APP_ARTIFACT_NAME="$APP_NAME-artifact-registry"
APP_VERSION="latest"
APP_SERVICE_ACCOUNT_NAME="tf-app-service-account"
APP_CUSTOM_ROLE="tfappCustomRole.$VERSION"
APP_PORT=9000
APP_ENV_FILE=".env.yaml"
MIN_INSTANCES=1
MAX_INSTANCES=1

echo "\n #----------Exporting Environment Variables is done.----------# \n"

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

EOF

# gcloud compute networks subnets list --network $
