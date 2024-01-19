# In model-deployment App Repository run this to update the app
cp -rf app-deployment/Main.py ~/Infrastructure-Automation-GCP/app
cp -rf app-deployment/pages/Agent.py app-deployment/pages/Toolkit.py ~/Infrastructure-Automation-GCP/app/pages
cp -rf app-deployment/.streamlit/config.toml ~/Infrastructure-Automation-GCP/app/.streamlit/
cp -rf test/* ~/Infrastructure-Automation-GCP/test
cp -rf makefile ~/Infrastructure-Automation-GCP/makefile

