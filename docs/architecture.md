# Architecture

## Overview

This lab implements a small Google Cloud environment designed to demonstrate practical infrastructure administration using low-cost resources.

```text
                              INTERNET
                                 |
                           HTTP TCP/80
                                 |
                                 v
                    +-------------------------+
                    |     Compute Engine      |
                    |      cloud-lab-vm       |
                    |        e2-micro         |
                    |    Ubuntu 24.04 LTS     |
                    |         Nginx           |
                    +-----------+-------------+
                                |
                     cloud-lab-vpc / subnet
                        10.10.10.0/24
                                |
                +---------------+----------------+
                |                                |
                v                                v
       Cloud Monitoring                    Cloud Logging
          + Alerting

VM attached identity:
cloud-lab-backup Service Account
                |
                | IAM-authorized API access
                v
          Cloud Storage bucket
              backups/
```

## Network

- VPC: `cloud-lab-vpc`
- Subnet: `cloud-lab-subnet`
- CIDR: `10.10.10.0/24`
- Region: `us-central1`
- Zone: `us-central1-a`

The VPC uses custom subnet mode instead of the default Google Cloud network.

## Compute

The workload runs on a Compute Engine VM:

- Name: `cloud-lab-vm`
- Machine type: `e2-micro`
- OS: Ubuntu 24.04 LTS
- Web server: Nginx

The instance receives a private address from `10.10.10.0/24` and a public IPv4 address for lab HTTP and SSH validation.

## Firewall

Two ingress rules were configured for the lab:

- TCP/80 from `0.0.0.0/0` for public HTTP testing
- TCP/22 from `0.0.0.0/0` for temporary SSH administration

Both rules target instances with the network tag `cloud-lab`.

For production, SSH should not remain broadly exposed. Recommended improvements include IAP, OS Login, source CIDR restrictions or private administrative access.

## Identity and access

Backup operations use the dedicated Service Account:

`cloud-lab-backup@gcp-cloud-infrastructure-lab.iam.gserviceaccount.com`

The Service Account is attached directly to the VM. The VM obtains workload credentials from the metadata service and uses IAM-authorized Google Cloud API calls to access Cloud Storage.

No Service Account key file is required.

## Storage

The Cloud Storage bucket is used as the backup destination for Nginx configuration and website content.

Backup source paths:

- `/etc/nginx`
- `/var/www/html`

Objects are uploaded under:

`backups/`

Cloud Storage is not mounted into the VPC or VM filesystem in this lab; it is accessed through the Cloud Storage API.

## Observability

Cloud Monitoring is used for VM metrics such as CPU, network and disk activity. A CPU threshold alert was configured for utilization above 80% for five minutes.

Cloud Logging is used to inspect infrastructure and Google Cloud service logs in Logs Explorer.

## Cost-conscious design

The initial version intentionally avoids components that would add unnecessary cost or complexity for the learning goal, such as GKE, Cloud NAT, Cloud SQL and external load balancing.

Later versions can add infrastructure as code, high availability, managed load balancing, containers and CI/CD.
