#!/bin/bash

# PolishMyCV Cloud Run Deployment Script
# This script builds and deploys the Flask application to Google Cloud Run

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SERVICE_NAME="polishmycv"
REGION="us-central1"  # Change this to your preferred region
IMAGE_NAME="gcr.io/\${PROJECT_ID}/${SERVICE_NAME}"

echo -e "${BLUE}🚀 PolishMyCV Cloud Run Deployment${NC}"
echo "=================================="

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}❌ Google Cloud SDK (gcloud) is not installed${NC}"
    echo "Please install it from: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Get current project ID
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
if [ -z "$PROJECT_ID" ]; then
    echo -e "${RED}❌ No Google Cloud project is set${NC}"
    echo "Please run: gcloud config set project YOUR_PROJECT_ID"
    exit 1
fi

echo -e "${GREEN}✅ Using project: ${PROJECT_ID}${NC}"

# Enable required APIs
echo -e "${YELLOW}🔧 Enabling required Google Cloud APIs...${NC}"
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable containerregistry.googleapis.com

# Build the Docker image
echo -e "${YELLOW}🏗️  Building Docker image...${NC}"
IMAGE_TAG="gcr.io/${PROJECT_ID}/${SERVICE_NAME}:latest"
gcloud builds submit --tag $IMAGE_TAG .

# Deploy to Cloud Run
echo -e "${YELLOW}🚀 Deploying to Cloud Run...${NC}"
gcloud run deploy $SERVICE_NAME \
    --image $IMAGE_TAG \
    --platform managed \
    --region $REGION \
    --allow-unauthenticated \
    --memory 4Gi \
    --cpu 2 \
    --max-instances 10 \
    --min-instances 0 \
    --port 8080 \
    --timeout 600 \
    --concurrency 80 \
    --set-env-vars "FLASK_ENV=production,PYTHONUNBUFFERED=1"

# Get the service URL
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --region=$REGION --format='value(status.url)')

echo ""
echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
echo "=================================="
echo -e "${BLUE}Service URL: ${SERVICE_URL}${NC}"
echo -e "${BLUE}Service Name: ${SERVICE_NAME}${NC}"
echo -e "${BLUE}Region: ${REGION}${NC}"
echo -e "${BLUE}Project: ${PROJECT_ID}${NC}"
echo ""
echo -e "${YELLOW}📝 Next steps:${NC}"
echo "1. Visit your application: $SERVICE_URL"
echo "2. Monitor logs: gcloud run logs tail $SERVICE_NAME --region=$REGION"
echo "3. View metrics in Cloud Console: https://console.cloud.google.com/run"
echo ""
echo -e "${GREEN}✅ Your PolishMyCV application is now live on Google Cloud Run!${NC}" 