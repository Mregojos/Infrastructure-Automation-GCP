rm -rf t*.tfstate
rm -rf t*.*.backup
rm -rf main.tf
rm -rf .t*.hcl
rm -rf .i*
gcloud compute firewall-rules delete $FIREWALL_RULES_NAME --quiet
gcloud run services delete $APP_NAME --region=$REGION --quiet
terraform destroy
