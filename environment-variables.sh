#---------Application Name Environment Variables----------#
source VERSION="i"
source APP_NAME="infra-auto-$VERSION"
source DB_PASSWORD="password" 
source ADMIN_PASSWORD="password"
source SPECIAL_NAME="guest"

#---------Project Environment Variables---------#
source PROJECT_NAME="$(gcloud config get project)"

#----------Database Instance Environment Variables----------#
source VPC_NAME="$APP_NAME-vpc"
source SUBNET_NAME="$APP_NAME-subnet"
source RANGE_A='10.100.0.0/20'
source RANGE_B='10.200.0.0/20'
source DB_INSTANCE_NAME="$APP_NAME-db"
source MACHINE_TYPE="e2-micro"
source REGION="us-west1"
source ZONE="us-west1-a"
source BOOT_DISK_SIZE="30"
source TAGS="db"
source FIREWALL_RULES_NAME="$APP_NAME-ports"
source STATIC_IP_ADDRESS_NAME="db-static-ip-address"
source BUCKET_NAME="$APP_NAME-startup-script"
source STARTUP_SCRIPT_BUCKET_SA="startup-script-bucket-sa"
source STARTUP_SCRIPT_BUCKET_CUSTOM_ROLE="bucketCustomRole.$VERSION"
# source STARTUP_SCRIPT_NAME="$APP_NAME-startup-script.sh"

# For Notebook 
source NOTEBOOK_REGION='us-central1'
source RANGE_C='10.150.0.0/20'

#---------Database Credentials----------#
source DB_CONTAINER_NAME="$APP_NAME-postgres-sql"
source DB_NAME="$APP_NAME-admin"
source DB_USER="$APP_NAME-admin" 
# source DB_HOST=$(gcloud compute addresses describe $STATIC_IP_ADDRESS_NAME --region $REGION | grep "address: " | cut -d " " -f2)
source DB_HOST=$(gcloud compute instances list --filter="name=$DB_INSTANCE_NAME" --format="value(networkInterfaces[0].accessConfigs[0].natIP)") 
source DB_PORT=5000
source DB_PASSWORD=$DB_PASSWORD
source ADMIN_PASSWORD=$ADMIN_PASSWORD 
source APP_PORT=9000
source APP_ADDRESS=""
source DOMAIN_NAME=""
source SPECIAL_NAME=$SPECIAL_NAME

#----------Deployment Environment Variables----------#
source CLOUD_BUILD_REGION="us-west2"
source REGION="us-west1"
source APP_ARTIFACT_NAME="$APP_NAME-artifact-registry"
source APP_VERSION="latest"
source APP_SERVICE_ACCOUNT_NAME="app-service-account"
source APP_CUSTOM_ROLE="appCustomRole.$VERSION"
source APP_PORT=9000
source APP_ENV_FILE=".env.yaml"
source MIN_INSTANCES=1
source MAX_INSTANCES=1

echo "\n #----------Exporting Environment Variables is done.----------# \n"