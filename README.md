# Infrastructure Automation on GCP

## Objective
* To automate the creation of GCP Services using Shell Scripting CLI and other IaC Tools.

## Architecture Design

## GCP Services
* Custom VPC with three subnets -> App Network
* Static IP Address -> Database Static Ip Address
* Cloud Storage -> Store Startup Script 
* IAM Service Account  -> For Security
* IAM Custom Role -> For Security 
* Compute Engine -> Database Server
* Artifact Registry -> Store Container Image
* Cloud Build -> Build the image
* Cloud Run -> Run the App
* Vertex AI Language Model -> Chat Language Model

---
Resources:
* GitHub Repository: https://github.com/mregojos/infrastructure-automation-gcp
* App Repository: https://github.com/mregojos/model-deployment
* CI/CD on GCP: https://github.com/mregojos/CI-CD-GCP
* Tech Stack GitHub Repository: https://github.com/mregojos/tech-stack
* Google Cloud Docs: https://cloud.google.com/docs