# Deployment Guide

This document records the main commands used to deploy the V1 environment.

## 1. Configure project, region and zone

```bash
gcloud config set project gcp-cloud-infrastructure-lab
gcloud config set compute/region us-central1
gcloud config set compute/zone us-central1-a
```

## 2. Create the custom VPC

```bash
gcloud compute networks create cloud-lab-vpc --subnet-mode=custom
```

## 3. Create the subnet

```bash
gcloud compute networks subnets create cloud-lab-subnet --network=cloud-lab-vpc --region=us-central1 --range=10.10.10.0/24
```

## 4. Create firewall rules

HTTP:

```bash
gcloud compute firewall-rules create allow-http-cloud-lab --network=cloud-lab-vpc --allow=tcp:80 --source-ranges=0.0.0.0/0 --target-tags=cloud-lab
```

SSH:

```bash
gcloud compute firewall-rules create allow-ssh-cloud-lab --network=cloud-lab-vpc --allow=tcp:22 --source-ranges=0.0.0.0/0 --target-tags=cloud-lab
```

## 5. Create the VM

```bash
gcloud compute instances create cloud-lab-vm --zone=us-central1-a --machine-type=e2-micro --network=cloud-lab-vpc --subnet=cloud-lab-subnet --image-family=ubuntu-2404-lts-amd64 --image-project=ubuntu-os-cloud --boot-disk-size=20GB --boot-disk-type=pd-standard --tags=cloud-lab
```

## 6. Connect through SSH

```bash
gcloud compute ssh cloud-lab-vm --zone=us-central1-a
```

## 7. Install Nginx

```bash
sudo apt update
sudo apt install nginx -y
sudo systemctl status nginx
curl localhost
```

## 8. Create a Cloud Storage bucket

```bash
gcloud storage buckets create gs://carleandro-gcp-cloud-lab-2026 --location=us-central1 --default-storage-class=STANDARD
```

## 9. Create the backup Service Account

```bash
gcloud iam service-accounts create cloud-lab-backup --display-name="Cloud Lab Backup Service Account"
```

Grant bucket object access:

```bash
gcloud storage buckets add-iam-policy-binding gs://carleandro-gcp-cloud-lab-2026 --member="serviceAccount:cloud-lab-backup@gcp-cloud-infrastructure-lab.iam.gserviceaccount.com" --role="roles/storage.objectUser"
```

## 10. Attach the Service Account to the VM

Stop the VM:

```bash
gcloud compute instances stop cloud-lab-vm --zone=us-central1-a
```

Attach the identity:

```bash
gcloud compute instances set-service-account cloud-lab-vm --zone=us-central1-a --service-account=cloud-lab-backup@gcp-cloud-infrastructure-lab.iam.gserviceaccount.com --scopes=https://www.googleapis.com/auth/cloud-platform
```

Start the VM:

```bash
gcloud compute instances start cloud-lab-vm --zone=us-central1-a
```

## 11. Create and upload a backup

```bash
mkdir -p ~/backups
sudo tar -czf ~/backups/nginx-backup.tar.gz /etc/nginx /var/www/html
gcloud storage cp ~/backups/nginx-backup.tar.gz gs://carleandro-gcp-cloud-lab-2026/backups/
```

Validate:

```bash
gcloud storage ls gs://carleandro-gcp-cloud-lab-2026/backups/
```

## 12. Monitoring and logging

A custom Monitoring dashboard was created for the VM, along with a high CPU alert policy. Logs were validated in Cloud Logging using the Logs Explorer.
