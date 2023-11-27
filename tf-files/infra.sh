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
STARTUP_SCRIPT_NAME="startup-script"

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

# For Startup Script
cat > startup-script.txt << EOF
gcloud storage cp gs://$BUCKET_NAME/startup-script .
sh startup-script.sh
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

resource "google_storage_bucket" "$BUCKET_NAME" {
    name = "$BUCKET_NAME"
    location = "US"
    force_destroy = true
}

resource "google_storage_bucket_object" "startup-script-object" {
    name = "$STARTUP_SCRIPT_NAME"
    source = "app/$STARTUP_SCRIPT_NAME.sh"
    bucket = "$BUCKET_NAME"
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
    project = "$PROJECT_NAME"
    role = "projects/$(gcloud config get project)/roles/$STARTUP_SCRIPT_BUCKET_CUSTOM_ROLE"
    members = [
        "serviceAccount:$STARTUP_SCRIPT_BUCKET_SA@$(gcloud config get project).iam.gserviceaccount.com"
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
        network = "$VPC_NAME"
        subnetwork = "$SUBNET_NAME-$REGION"
        access_config {
            nat_ip = "$(gcloud compute addresses describe $STATIC_IP_ADDRESS_NAME --region $REGION | grep "address: " | cut -d " " -f2)"
        }
    }
    metadata_startup_script = "starrtup-script.txt"
    service_account {
        email = "$STARTUP_SCRIPT_BUCKET_SA@$(gcloud config get project).iam.gserviceaccount.com"
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
    role = "projects/$(gcloud config get project)/roles/$APP_CUSTOM_ROLE"
    members = [
        "serviceAccount:$APP_SERVICE_ACCOUNT_NAME@$(gcloud config get project).iam.gserviceaccount.com"
        ]
}

EOF

# gcloud compute networks subnets list --network=$VPC_NAME

# sh infra.sh && sh tf.sh

sh tf.sh

echo "\n GCP Services successful created. \n"

cd app

# build and submnit an image to Artifact Registry
gcloud builds submit \
    --region=$CLOUD_BUILD_REGION \
    --tag $REGION-docker.pkg.dev/$(gcloud config get-value project)/$APP_ARTIFACT_NAME/$APP_NAME:$APP_VERSION
echo "\n #----------Docker image has been successfully built.----------# \n"

# DB_INSTANCE_NAME Address / Host
DB_HOST=$(gcloud compute instances list --filter="name=$DB_INSTANCE_NAME" --format="value(networkInterfaces[0].accessConfigs[0].natIP)") 

# Environment Variables for the app
echo """
DB_NAME:
    '$DB_NAME'
DB_USER:
    '$DB_USER'
DB_HOST:
    '$DB_HOST'
DB_PORT:
    '$DB_PORT'
DB_PASSWORD:
    '$DB_PASSWORD'
PROJECT_NAME:
    '$PROJECT_NAME'
ADMIN_PASSWORD:
    '$ADMIN_PASSWORD'
APP_PORT:
    '$APP_PORT'
APP_ADDRESS:
    '$APP_ADDRESS'
DOMAIN_NAME:
    '$DOMAIN_NAME'
SPECIAL_NAME:
    '$SPECIAL_NAME'
""" > .env.yaml


# Deploy the app using Cloud Run
gcloud run deploy $APP_NAME \
    --max-instances=$MAX_INSTANCES --min-instances=$MIN_INSTANCES --port=$APP_PORT \
    --env-vars-file=$APP_ENV_FILE \
    --image=$REGION-docker.pkg.dev/$(gcloud config get project)/$APP_ARTIFACT_NAME/$APP_NAME:$APP_VERSION \
    --allow-unauthenticated \
    --region=$REGION \
    --service-account=$APP_SERVICE_ACCOUNT_NAME@$(gcloud config get project).iam.gserviceaccount.com 
echo "\n #----------The application has been successfully deployed.----------# \n"