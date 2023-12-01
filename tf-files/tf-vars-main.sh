cat > terraform.tfvars << EOF
tf_project = "$PROJECT_NAME"
tf_vpc_name = "$VPC_NAME"
tf_bucket_name = "$BUCKET_NAME"
tf_role = "projects/$(gcloud config get project)/roles/$STARTUP_SCRIPT_BUCKET_CUSTOM_ROLE"
tf_member = "serviceAccount:$STARTUP_SCRIPT_BUCKET_SA@$(gcloud config get project).iam.gserviceaccount.com"
tf_metadata_startup_script = "gcloud storage cp gs://$BUCKET_NAME/startup-script.sh . \n sh startup-script.sh"
tf_email = "$STARTUP_SCRIPT_BUCKET_SA@$(gcloud config get project).iam.gserviceaccount.com"
tf_app_role = "projects/$(gcloud config get project)/roles/$APP_CUSTOM_ROLE"
tf_app_member = "serviceAccount:$APP_SERVICE_ACCOUNT_NAME@$(gcloud config get project).iam.gserviceaccount.com"
EOF

cat > variables.tf << EOF
variable "tf_project_name" {}
variable "tf_region" {
    default = "northamerica-northeast1"
}
variable "tf_zone" {
    default = "northamerica-northeast1-a"
}
variable "tf_vpc_name" {}
variable "tf_bucket_name" {}
variable "tf_role" {}
variable "tf_member" {}
variable "tf_metadata_startup_script" {}
variable "tf_email" {}
variable "tf_app_role" {}
variable "tf_app_member" {}
EOF

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
  project = var.tf_project
  region  = var.tf_region
  zone    = var.tf_zone
}

# Create VPC Network resource
resource "google_compute_network" "tf_vpc" {
  name = var.tf_vpc_name
  auto_create_subnetworks = false
  mtu = 1460
}

# Create three subnets
resource "google_compute_subnetwork" "$REGION" {
  name          = "$SUBNET_NAME-$REGION"
  ip_cidr_range = "$RANGE_A"
  region        = "$REGION"
  network       = google_compute_network.tf_vpc.id
}

resource "google_compute_subnetwork" "$CLOUD_BUILD_REGION" {
  name          = "$SUBNET_NAME-$CLOUD_BUILD_REGION"
  ip_cidr_range = "$RANGE_B"
  region        = "$CLOUD_BUILD_REGION"
  network       = google_compute_network.tf_vpc.id
}

resource "google_compute_subnetwork" "$NOTEBOOK_REGION" {
  name          = "$SUBNET_NAME-$NOTEBOOK_REGION"
  ip_cidr_range = "$RANGE_C"
  region        = "$NOTEBOOK_REGION"
  network       = google_compute_network.tf_vpc.id
}

resource "google_compute_address" "$STATIC_IP_ADDRESS_NAME" {
    name = "$STATIC_IP_ADDRESS_NAME"
    region = "$REGION"
}

resource "google_storage_bucket" "tf_bucket" {
    name = var.tf_bucket_name
    location = "US"
    force_destroy = true
}

resource "google_storage_bucket_object" "startup-script-object" {
    name = "$STARTUP_SCRIPT_NAME.sh"
    source = "app/$STARTUP_SCRIPT_NAME.sh"
    bucket = google_storage_bucket.tf_bucket.id
}

resource "google_service_account" "$STARTUP_SCRIPT_BUCKET_SA" {
    account_id = "$STARTUP_SCRIPT_BUCKET_SA"
    display_name = "$STARTUP_SCRIPT_BUCKET_SA"
}

resource "google_project_iam_custom_role" "BUCKET_CUSTOM_ROLE" {
    role_id = "$STARTUP_SCRIPT_BUCKET_CUSTOM_ROLE"
    title = "$STARTUP_SCRIPT_BUCKET_CUSTOM_ROLE"
    description = "Get the object only"
    permissions = ["storage.objects.get"]
}

resource "google_project_iam_binding" "BUCKET_BINDING" {
    project = var.tf_project
    role = var.tf_role
    members = [
        var.tf_member
        ]
}

resource "google_compute_instance" "$DB_INSTANCE_NAME" {
    name = "$DB_INSTANCE_NAME"
    machine_type = "$MACHINE_TYPE"
    zone = "$ZONE"
    tags = ["$TAGS"]
    boot_disk {
        initialize_params {
        image = "debian-cloud/debian-11"
        }
    }
    network_interface {
        network = var.tf_vpc_name
        subnetwork = google_compute_subnetwork.$REGION.name
        access_config {
            nat_ip = google_compute_address.$STATIC_IP_ADDRESS_NAME.address
        }
    }
    metadata_startup_script = var.tf_metadata_startup_script
    service_account {
        email = var.tf_email
        scopes = ["cloud-platform"]
    }
    
}

resource "google_artifact_registry_repository" "$APP_ARTIFACT_NAME" {
    location = "$REGION"
    repository_id = "$APP_ARTIFACT_NAME"
    description = "Docker repository"
    format = "DOCKER"
}

resource "google_service_account" "$APP_SERVICE_ACCOUNT_NAME" {
    account_id = "$APP_SERVICE_ACCOUNT_NAME"
    display_name = "$APP_SERVICE_ACCOUNT_NAME"
}

resource "google_project_iam_custom_role" "APP_CUSTOM_ROLE" {
    role_id = "$APP_CUSTOM_ROLE"
    title = "$APP_CUSTOM_ROLE"
    description = "Predict Only"
    permissions = ["aiplatform.endpoints.predict"]
}

resource "google_project_iam_binding" "APP_BINDING" {
    project = "$PROJECT_NAME"
    role = var.tf_app_role
    members = [
        var.tf_app_member
        ]
}

resource "google_compute_firewall" "$FIREWALL_RULES_NAME" {
    name = "$FIREWALL_RULES_NAME"
    allow {
      ports = ["5000", "8000"]
      protocol = "tcp"
    }
    direction = "INGRESS"
    network = google_compute_network.tf_vpc.name
    priority = 1000
    source_ranges = ["0.0.0.0/0"]
    target_tags = ["$TAGS"]
}

EOF

# sh tf.sh

echo "\n GCP Services successful created. \n"