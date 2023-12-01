#----------Enable Artifact Registry, Cloud Build, and Cloud Run, Vertex AI
# gcloud services list --available
gcloud services enable compute.googleapis.com iam.googleapis.com cloudbuild.googleapis.com artifactregistry.googleapis.com run.googleapis.com aiplatform.googleapis.com cloudresourcemanager.googleapis.com
echo "\n #----------Services have been successfully enabled.----------# \n"

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
    name = "$STARTUP_SCRIPT_NAME.sh"
    source = "app/$STARTUP_SCRIPT_NAME.sh"
    bucket = google_storage_bucket.$BUCKET_NAME.id
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
            nat_ip = google_compute_address.$STATIC_IP_ADDRESS_NAME.address
        }
    }
    metadata_startup_script = "gcloud storage cp gs://$BUCKET_NAME/startup-script.sh . \n sh startup-script.sh"
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

sh tf.sh

echo "\n GCP Services successful created. \n"

cd app

# FIREWALL RULE
gcloud compute --project=$(gcloud config get project) firewall-rules create $FIREWALL_RULES_NAME \
    --direction=INGRESS --priority=1000 --network=$VPC_NAME --action=ALLOW --rules=tcp:5000,tcp:8000 --source-ranges=0.0.0.0/0   \
     --target-tags=$TAGS

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