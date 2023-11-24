# Infrastructure Automation on GCP

---
## Objective
* To automate the creation and provision of GCP Services using shell scripting, gcloud CLI and other IaC Tools

---
## Architecture Design


---
## GCP Services
![Infrastructire Automation GCP](images/infra.drawio.png)

* Custom VPC with three subnets -> App Network
* Static IP Address -> Database Static Ip Address
* Cloud Storage -> Store Startup Script 
* IAM Service Account  -> For Security
* IAM Custom Role -> For Security 
* Compute Engine -> Database Server
* Artifact Registry -> Store Container Image
* Cloud Build -> Build the image and submit to Artifact Registry
* Cloud Run -> Run the App
* Vertex AI Language Model -> Chat Language Model

---
### Using gcloud and shell scripting

#### Prerequisite
* GCP Account
* Project Owner Role

```sh
# Automate the GCP Services Creation
sh infrastructure-automation-gcp.sh

# Clean Up
sh cleanup.sh
```

---
Resources:
* GitHub Repository: https://github.com/mregojos/infrastructure-automation-gcp
* App Repository: https://github.com/mregojos/model-deployment
* CI/CD on GCP: https://github.com/mregojos/CI-CD-GCP
* Tech Stack GitHub Repository: https://github.com/mregojos/tech-stack
* Google Cloud Docs: https://cloud.google.com/docs