# Deployment Guide

This document records the main commands used to deploy and validate the V1 environment.

## 1. Configure project, region and zone

```bash
gcloud config set project gcp-cloud-infrastructure-lab
gcloud config set compute/region us-central1
gcloud config set compute/zone us-central1-a
```

Validate:

```bash
gcloud config list
```

## 2. Create the custom VPC

```bash
gcloud compute networks create cloud-lab-vpc \
  --subnet-mode=custom
```

## 3. Create the subnet

```bash
gcloud compute networks subnets create cloud-lab-subnet \
  --network=cloud-lab-vpc \
  --region=us-central1 \
  --range=10.10.10.0/24
```

Validate:

```bash
gcloud compute networks subnets list --filter="network:cloud-lab-vpc"
```

## 4. Create firewall rules

HTTP:

```bash
gcloud compute firewall-rules create allow-http-cloud-lab \
  --network=cloud-lab-vpc \
  --allow=tcp:80 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=cloud-lab
```

SSH:

```bash
gcloud compute firewall-rules create allow-ssh-cloud-lab \
  --network=cloud-lab-vpc \
  --allow=tcp:22 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=cloud-lab
```

> The SSH rule is intentionally broad for this temporary lab. Restrict it in production.

## 5. Create the VM

```bash
gcloud compute instances create cloud-lab-vm \
  --zone=us-central1-a \
  --machine-type=e2-micro \
  --network=cloud-lab-vpc \
  --subnet=cloud-lab-subnet \
  --image-family=ubuntu-2404-lts-amd64 \
  --image-project=ubuntu-os-cloud \
  --boot-disk-size=20GB \
  --boot-disk-type=pd-standard \
  --tags=cloud-lab
```

Validate:

```bash
gcloud compute instances list
```

## 6. Connect through SSH

```bash
gcloud compute ssh cloud-lab-vm --zone=us-central1-a
```

## 7. Install and validate Nginx

```bash
sudo apt update
sudo apt install nginx -y
sudo systemctl status nginx
curl localhost
```

The default web page was then replaced with a custom lab page under `/var/www/html/index.html`.

## 8. Create a Cloud Storage bucket

Run from Cloud Shell:

```bash
gcloud storage buckets create gs://carleandro-gcp-cloud-lab-2026 \
  --location=us-central1 \
  --default-storage-class=STANDARD
```

Validate:

```bash
gcloud storage buckets list
```

## 9. Create the backup Service Account

```bash
gcloud iam service-accounts create cloud-lab-backup \
  --display-name="Cloud Lab Backup Service Account"
```

Grant bucket-level object access:

```bash
gcloud storage buckets add-iam-policy-binding \
  gs://carleandro-gcp-cloud-lab-2026 \
  --member="serviceAccount:cloud-lab-backup@gcp-cloud-infrastructure-lab.iam.gserviceaccount.com" \
  --role="roles/storage.objectUser"
```

## 10. Attach the Service Account to the VM

Stop the VM:

```bash
gcloud compute instances stop cloud-lab-vm --zone=us-central1-a
```

Attach the identity and Cloud Platform OAuth scope:

```bash
gcloud compute instances set-service-account cloud-lab-vm \
  --zone=us-central1-a \
  --service-account=cloud-lab-backup@gcp-cloud-infrastructure-lab.iam.gserviceaccount.com \
  --scopes=https://www.googleapis.com/auth/cloud-platform
```

Start the VM:

```bash
gcloud compute instances start cloud-lab-vm --zone=us-central1-a
```

Validate the attached identity:

```bash
gcloud compute instances describe cloud-lab-vm \
  --zone=us-central1-a \
  --format="get(serviceAccounts.email)"
```

## 11. Create and upload a backup

On the VM:

```bash
mkdir -p ~/backups
sudo tar -czf ~/backups/nginx-backup.tar.gz /etc/nginx /var/www/html
gcloud storage cp ~/backups/nginx-backup.tar.gz \
  gs://carleandro-gcp-cloud-lab-2026/backups/
```

Validate:

```bash
gcloud storage ls gs://carleandro-gcp-cloud-lab-2026/backups/
```

A reusable version of this process is available in [`../scripts/backup.sh`](../scripts/backup.sh).

## 12. Monitoring

A custom Cloud Monitoring dashboard was created for the VM with CPU, network and disk metrics.

A CPU alert policy was configured with a threshold above 80% for five minutes.

## 13. Logging

Cloud Logging was validated in Logs Explorer using a VM resource query such as:

```text
resource.type="gce_instance"
```

## 14. Cost control

A Cloud Billing budget was configured for the project with threshold notifications at 50%, 75%, 90% and 100%.

## Cleanup

When the lab is no longer needed, stop or delete billable resources to avoid unnecessary charges. Examples:

```bash
gcloud compute instances stop cloud-lab-vm --zone=us-central1-a
```

For permanent teardown, review dependencies before deleting the VM, firewall rules, subnet, VPC, bucket and Service Account.
