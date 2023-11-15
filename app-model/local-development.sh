# Local Development

# Objective
# * To deply a pre-trained model on GCP

# Environment Variables
APP_NAME="app"
FIREWALL_RULES_NAME="ports"

# Build
docker build -t $APP_NAME .
# Run
docker run -d -p 9000:9000 -v $(pwd):/app --name $APP_NAME $APP_NAME
# Create a firewall (GCP)
gcloud compute --project=$(gcloud config get project) firewall-rules create $FIREWALL_RULES_NAME \
    --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:5000,tcp:8000,tcp:9000 --source-ranges=0.0.0.0/0 
# Remove docker container
# docker rm -f $APP_NAME