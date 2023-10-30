# Infrastructure Automation on GCP

---
    Infrastructure Automation Services
        Infrastructure as Code
            Open-Source: Terraform
        Configuration Management
            Open-Source: Ansible
        Pipeline for automation 
            Repository: Cloud Repositories
            Build Trigger: Cloud Build
        
---

    Project
        > IaC (GCP Services) to create
            * Virtual Private Network
            * Compute Engine
            * Cloud Storage Bucket
            * Cloud SQL
            * etc.
        > IaC Files-> GCP Services
            * Initialize
            * Plan
            * Apply
            * Destroy
        > IaC Files -> Storage (To save state)
        > Configuration Management (To update and install applications)
        
        Automate the creation by using a pipeline
        > IaC Files -> Repository -> Build Trigger -> GCP Services
         
        
        