#----------Enable Artifact Registry, Cloud Build, and Cloud Run, Vertex AI
# gcloud services list --available
gcloud services enable compute.googleapis.com iam.googleapis.com cloudbuild.googleapis.com artifactregistry.googleapis.com run.googleapis.com aiplatform.googleapis.com cloudresourcemanager.googleapis.com
echo "\n #----------Services have been successfully enabled.----------# \n"

# Without using variables
# sh tf-main.sh

# With variables
sh tf-vars-main.sh

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