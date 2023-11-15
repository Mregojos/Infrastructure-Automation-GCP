# Local Development

# Objective
# * To deply a pre-trained model on GCP

# Environment Variables
APP_NAME="app-dev"
# APP_NAME="simple-app"
FIREWALL_RULES_NAME="ports"

# Database
# With volume/data connected
# cd app-model 
# cd app-model
docker run -d \
    --name postgres-sql \
    -e POSTGRES_USER=matt \
    -e POSTGRES_PASSWORD=password \
    -v $(pwd)/data/:/var/lib/postgresql/data/ \
    -p 5000:5432 \
    postgres
docker run -p 8000:80 \
    -e 'PGADMIN_DEFAULT_EMAIL=matt@example.com' \
    -e 'PGADMIN_DEFAULT_PASSWORD=password' \
    -d dpage/pgadmin4

# For App Development
cd app-dev
# Build
docker build -t $APP_NAME .
# Run
docker run -d -p 9000:9000 -v $(pwd):/app --name $APP_NAME $APP_NAME
# Create a firewall (GCP)
gcloud compute --project=$(gcloud config get project) firewall-rules create $FIREWALL_RULES_NAME \
    --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:5000,tcp:8000,tcp:9000 --source-ranges=0.0.0.0/0 
# Remove docker container
# docker rm -f $APP_NAME
# Remove docker container all
# docker rm -f $(docker ps -aq)
# Docker exec
# docker exec -it $APP_NAME sh

# Environment Variables for the app
echo """DBNAME="matt" 
USER="matt" 
HOST="" 
DBPORT="5000" 
DBPASSWORD="password" 
PROJECT_NAME="matt-0706"
""" > app-dev/env.sh

# Enable Artifact Registry, Cloud Build, and Cloud Run, Vertex AI
# !gcloud services list --available
gcloud services enable cloudbuild.googleapis.com artifactregistry.googleapis.com run.googleapis.com aiplatform.googleapis.com cloudresourcemanager.googleapis.com
echo "\n #----------Services have been successfully enabled.----------# \n"

#----------Delete Resources----------#
gcloud compute instances delete $DB_NAME --zone=$ZONE --quiet