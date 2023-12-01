#----------Enable Artifact Registry, Cloud Build, and Cloud Run, Vertex AI
# gcloud services list --available
gcloud services enable compute.googleapis.com iam.googleapis.com cloudbuild.googleapis.com artifactregistry.googleapis.com run.googleapis.com aiplatform.googleapis.com cloudresourcemanager.googleapis.com
echo "\n #----------Services have been successfully enabled.----------# \n"

# Without using variables
# sh tf-main.sh

# With variables
sh tf-vars-main.sh

cat >> terraform.tfvars << EOF
tf_bucket_backend = "$APP_NAME-tf-bucket-backend"
EOF

cat >> variables.tf << EOF
variable "tf_bucket_backend"
EOF

cat > bucket-backend.tf << EOF
resource "google_storage_bucket" "tf_bucket_backend" {
    name = var.tf_bucket_bakend
    force_destroy = false
    location = "US"
    storage_class = "STANDARD"
    versioning {
      enabled = true
    }
}
EOF


cat > backend.tf << EOF
terraform {
    bakend "gcs" {
        bucket = var.tf_bucket_bakend
        prefix = "terraform/state"
    }
}
EOF