# PolishMyCV - Google Cloud Run Deployment Guide

This guide will help you deploy the PolishMyCV Flask application to Google Cloud Run.

## 🚀 Quick Deployment

### Prerequisites

1. **Google Cloud Account**: Create one at [cloud.google.com](https://cloud.google.com)
2. **Google Cloud SDK**: Install from [cloud.google.com/sdk](https://cloud.google.com/sdk/docs/install)
3. **Docker** (optional): For local testing

### Step 1: Setup Google Cloud Project

```bash
# Login to Google Cloud
gcloud auth login

# Create a new project (or use existing)
gcloud projects create YOUR_PROJECT_ID --name="PolishMyCV"

# Set the project
gcloud config set project YOUR_PROJECT_ID

# Enable billing (required for Cloud Run)
# Go to: https://console.cloud.google.com/billing
```

### Step 2: Clone and Deploy

```bash
# Clone the repository
git clone https://github.com/hyperpix/pcv.git
cd pcv

# Run the automated deployment script
bash deploy-to-cloudrun.sh
```

That's it! The script will:
- ✅ Enable required Google Cloud APIs
- ✅ Build the Docker image using Cloud Build
- ✅ Deploy to Cloud Run
- ✅ Configure all necessary settings
- ✅ Provide you with the live URL

## 📋 Manual Deployment Steps

If you prefer manual deployment or need to customize settings:

### 1. Enable APIs

```bash
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable containerregistry.googleapis.com
```

### 2. Build and Deploy

```bash
# Build the image
gcloud builds submit --tag gcr.io/YOUR_PROJECT_ID/polishmycv

# Deploy to Cloud Run
gcloud run deploy polishmycv \
    --image gcr.io/YOUR_PROJECT_ID/polishmycv \
    --platform managed \
    --region us-central1 \
    --allow-unauthenticated \
    --memory 2Gi \
    --cpu 1 \
    --max-instances 10 \
    --port 8080 \
    --timeout 300
```

## 🔧 Configuration Options

### Environment Variables

You can set environment variables during deployment:

```bash
gcloud run deploy polishmycv \
    --set-env-vars "FLASK_ENV=production,GEMINI_API_KEY=your_key_here"
```

### Resource Limits

- **Memory**: 2Gi (recommended for PDF processing)
- **CPU**: 1 vCPU (can be adjusted based on load)
- **Timeout**: 300 seconds (for large file processing)
- **Concurrency**: 80 requests per instance

### Scaling Configuration

- **Min Instances**: 0 (scales to zero when not in use)
- **Max Instances**: 10 (adjust based on expected traffic)

## 🔍 Monitoring and Logs

### View Logs
```bash
gcloud run logs tail polishmycv --region=us-central1
```

### Monitor Performance
Visit the [Cloud Console](https://console.cloud.google.com/run) to view:
- Request metrics
- Error rates
- Response times
- Resource utilization

## 🛠️ Troubleshooting

### Common Issues

1. **Build Failures**
   - Check Dockerfile syntax
   - Ensure all dependencies are in requirements.txt
   - Verify Python version compatibility

2. **Memory Issues**
   - Increase memory allocation to 4Gi if needed
   - Monitor memory usage in Cloud Console

3. **Timeout Issues**
   - Increase timeout for large file processing
   - Optimize PDF generation process

4. **Permission Errors**
   - Ensure proper IAM roles are assigned
   - Check service account permissions

### Debug Commands

```bash
# Check service status
gcloud run services describe polishmycv --region=us-central1

# View recent deployments
gcloud run revisions list --service=polishmycv --region=us-central1

# Test locally with Docker
docker build -t polishmycv .
docker run -p 8080:8080 polishmycv
```

## 💰 Cost Optimization

Cloud Run pricing is based on:
- **CPU and Memory**: Only charged when processing requests
- **Requests**: $0.40 per million requests
- **Networking**: Egress charges may apply

### Cost-Saving Tips:
1. Use minimum required memory (2Gi for this app)
2. Set appropriate timeout values
3. Enable scale-to-zero for development environments
4. Monitor usage in Cloud Console

## 🔒 Security Best Practices

1. **Environment Variables**: Store sensitive data in Secret Manager
2. **Authentication**: Enable IAM authentication for production
3. **HTTPS**: Cloud Run provides HTTPS by default
4. **Network Security**: Configure VPC if needed

## 📈 Production Considerations

### High Availability
- Deploy to multiple regions
- Use Cloud Load Balancer for global distribution
- Implement health checks

### Performance
- Enable Cloud CDN for static assets
- Use Cloud Storage for file uploads
- Implement caching strategies

### Backup and Recovery
- Regular database backups (if using Cloud SQL)
- Version control for application code
- Disaster recovery planning

## 🔄 CI/CD Pipeline

The repository includes `cloudbuild.yaml` for automated deployments:

1. **Trigger Setup**: Connect GitHub repository to Cloud Build
2. **Automatic Builds**: Builds trigger on git push
3. **Automated Testing**: Add test steps to cloudbuild.yaml
4. **Blue-Green Deployments**: Use Cloud Run revisions

## 📞 Support

For deployment issues:
1. Check the [Cloud Run documentation](https://cloud.google.com/run/docs)
2. Review application logs
3. Monitor Cloud Console metrics
4. Contact Google Cloud Support if needed

## 🎯 Next Steps

After successful deployment:
1. Configure custom domain
2. Set up monitoring and alerting
3. Implement user authentication
4. Add database persistence
5. Configure backup strategies

---

**🎉 Congratulations!** Your PolishMyCV application is now running on Google Cloud Run with enterprise-grade scalability and reliability. 