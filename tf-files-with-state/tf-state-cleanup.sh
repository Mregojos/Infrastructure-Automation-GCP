gcloud run services delete $APP_NAME --region=$REGION --quiet
terraform destroy -auto-approve
rm -rf t*.tfstate
rm -rf t*.*.backup
rm -rf main.tf
rm -rf .t*.hcl
rm -rf .i*
rm -rf .t*
rm -rf *.t*
gcloud storage rm -r gs://$APP_NAME-tf-bucket-backend