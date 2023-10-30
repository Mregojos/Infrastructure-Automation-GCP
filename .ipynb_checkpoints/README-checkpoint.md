# Infrastructure Automation on GCP

---
    Infrastructure Automation Services
        Infrastructure as Code: 
            * Terraform (Open-Source)
        Configuration Management
            * Ansible (Open-Source)
        Pipeline for automation 
            * Repository: Cloud Repositories
            * Build Trigger: Cloud Build
        
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
         
        
 ---
 Reference:
     
    | Repository Website: https://github.com/mregojos/infrastructure-automation-gcp
    | Google Cloud Docs: cloud.google.com/docs
    | Terraform Docs: terraform.io/docs
    | Ansible Docs: ansible.com/docs 