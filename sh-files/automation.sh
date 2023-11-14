# Infrastructure Automation using Shell Scripting and gcloud CLI
# sh automation.sh

# Environment Variables
DB_NAME="db"
MACHINE_TYPE="e2-micro"
REGION="us-west1"
ZONE="us-west1-a"
BOOT_DISK_SIZE="30"
TAGS="db"
FIREWALL_RULES_NAME="ports"
STATIC_IP_ADDRESS_NAME="db-static-ip-address"
CLOUD_BUILD_REGION="us-west2"
APP_ARTIFACT_NAME="app"
APP_NAME="app"
APP_VERSION="latest"
APP_SERVICE_ACCOUNT_NAME='app-service-account'
BUCKET_NAME='matt-startup-script'
STARTUP_SCRIPT_BUCKET_SA='startup-script-bucket-sa'
STARTUP_SCRIPT_NAME='startup-script.sh'
echo -e "\n #----------Exporting Environment Variables is done.----------#"

# Enable Artifact Registry, Cloud Build, and Cloud Run, Vertex AI
# !gcloud services list --available
gcloud services enable cloudbuild.googleapis.com artifactregistry.googleapis.com run.googleapis.com aiplatform.googleapis.com cloudresourcemanager.googleapis.com
echo -e "\n #----------Services have been successfully enabled.----------#"

# Create a static external ip address
gcloud compute addresses create $STATIC_IP_ADDRESS_NAME --region $REGION
echo -e "#\n ----------Static IP Address has been successfully created.----------#"

# Make a bucket
gcloud storage buckets create gs://$BUCKET_NAME
echo -e "#\n ----------THe bucket has been successfully created.----------#"

# Copy the file to Cloud Storage
gcloud storage cp startup-script.sh gs://$BUCKET_NAME
echo -e "#\n ----------Startup script has been successfully copied.----------#"

# Create a service account
gcloud iam service-accounts create $STARTUP_SCRIPT_BUCKET_SA
echo -e "#\n ----------Bucket Service Account has been successfully created.----------#"

# Add IAM Policy Binding to the Bucket Service Account
gcloud projects add-iam-policy-binding \
    $(gcloud config get project) \
    --member=serviceAccount:$STARTUP_SCRIPT_BUCKET_SA@$(gcloud config get project).iam.gserviceaccount.com \
    --role=roles/storage.objectViewer
echo -e "#\n ----------Bucket Service Account IAM has been successfully binded.----------#"

# Print the Static IP Address
# gcloud compute addresses describe $STATIC_IP_ADDRESS_NAME --region $REGION | grep "address: " | cut -d " " -f2

# Create an instance with these specifications
gcloud compute instances create $DB_NAME \
    --machine-type=$MACHINE_TYPE --zone=$ZONE --tags=$TAGS \
    --boot-disk-size=$BOOT_DISK_SIZE \
    --service-account=$STARTUP_SCRIPT_BUCKET_SA@$(gcloud config get project).iam.gserviceaccount.com  \
    --metadata=startup-script-url=gs://$BUCKET_NAME/$STARTUP_SCRIPT_NAME \
    --network-interface=address=$(gcloud compute addresses describe $STATIC_IP_ADDRESS_NAME --region $REGION | grep "address: " | cut -d " " -f2)
echo -e "\n #----------Compute Instance has been successfully created.----------#"

# Create a firewall (GCP)
gcloud compute --project=$(gcloud config get project) firewall-rules create $FIREWALL_RULES_NAME \
    --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:5000 --source-ranges=0.0.0.0/0 \
    --target-tags=$TAGS
echo -e "\n #----------Firewall Rules has been successfully created.----------#"

# Create a Docker repository in Artifact Registry
gcloud artifacts repositories create $APP_ARTIFACT_NAME \
    --repository-format=docker \
    --location=$REGION \
    --description="Docker repository"
echo -e "\n #----------Artifact Repository has been successfully created.----------#"

# Change the directory
cd ..
cd app

# build and submnit an image to Artifact Registry
gcloud builds submit \
    --region=$CLOUD_BUILD_REGION \
    --tag $REGION-docker.pkg.dev/$(gcloud config get-value project)/$APP_NAME/$APP_NAME:$APP_VERSION
echo -e "\n #----------Docker image has been successfully built.----------#"

# For Cloud Run Deploy, use a Service Account with Cloud Run Admin
# For Clou Run Deployed Add (Service), use a Service Account with Vertex AI User or with custom IAM Role 
# Create IAM Service Account for the app
gcloud iam service-accounts create $APP_SERVICE_ACCOUNT_NAME
echo -e "\n #----------Service Account has been successfully created.----------#"

# Add IAM Policy Binding to the App Service Account
gcloud projects add-iam-policy-binding \
    $(gcloud config get project) \
    --member=serviceAccount:$APP_SERVICE_ACCOUNT_NAME@$(gcloud config get project).iam.gserviceaccount.com \
    --role=roles/aiplatform.user
echo -e "\n #----------App Service Account has been successfully binded.----------#"

# Change the directory
cd ..
cd sh-files

# Deploy the app using Cloud Run
gcloud run deploy $APP_NAME \
    --max-instances=1 --min-instances=1 --port=9000 \
    --env-vars-file=env.yaml \
    --image=$REGION-docker.pkg.dev/$(gcloud config get project)/$APP_NAME/$APP_NAME:$APP_VERSION \
    --allow-unauthenticated \
    --region=$REGION \
    --service-account=$APP_SERVICE_ACCOUNT_NAME@$(gcloud config get project).iam.gserviceaccount.com 
echo -e "\n #----------The application has been successfully deployed.----------#"