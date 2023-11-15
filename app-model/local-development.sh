# Local Development

# Objective
# * To deply a pre-trained model on GCP

# For simple-app
# Build
docker build -t simple-app .
# Run
docker run -d -p 9000:9000 -v $(pwd):/app --name simple-app simple-app
