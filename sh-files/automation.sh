# Infrastructure Automation using Shell Scripting and gcloud CLI

# Environment Variables
DB_NAME="db"
MACHINE_TYPE="e2-micro"
REGION="us-west1"
ZONE="us-west1-a"
BOOT_DISK_SIZE="30"
TAGS="db"
FIREWALL_RULES_NAME="ports"
STATIC_IP_ADDRESS_NAME="db-static-ip-address"
echo "Exporting Environment Variables is done."

# Create a static external ip address
gcloud compute addresses create $STATIC_IP_ADDRESS_NAME --region $REGION
echo "Static IP Address has been successfully created."

# Print the Static IP Address
# gcloud compute addresses describe $STATIC_IP_ADDRESS_NAME --region $REGION | grep "address: " | cut -d " " -f2

# Create an instance with these specifications
gcloud compute instances create $DB_NAME \
    --machine-type=$MACHINE_TYPE --zone=$ZONE --tags=$TAGS \
    --boot-disk-size=$BOOT_DISK_SIZE \
    --no-scopes --no-service-account \
    --metadata-from-file=startup-script=startup-script.sh \
    --network-interface=address=$(gcloud compute addresses describe $STATIC_IP_ADDRESS_NAME --region $REGION | grep "address: " | cut -d " " -f2)
echo "Compute Instance has been successfully created."

# Create a firewall (GCP)
gcloud compute --project=$(gcloud config get project) firewall-rules create $FIREWALL_RULES_NAME \
    --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:5000 --source-ranges=0.0.0.0/0 \
    --target-tags=$TAGS
echo "Firewall Rules has been successfully created."