# Security Notes

## IAM

The lab uses a dedicated Service Account for VM backup operations:

`cloud-lab-backup@gcp-cloud-infrastructure-lab.iam.gserviceaccount.com`

The goal is to avoid using personal credentials for workload access to Cloud Storage.

## Workload identity

The Service Account is attached directly to the Compute Engine VM. The VM uses short-lived credentials exposed through the Google Cloud metadata service, so no Service Account JSON key is required.

This is preferable to storing long-lived credentials on disk or in the repository.

## Least privilege

The first permission model used `roles/storage.objectCreator`. During validation, the `gcloud storage` workflow required additional object permissions for the lab's upload and verification steps, so the bucket-level role was adjusted to `roles/storage.objectUser`.

For production workloads, IAM should be reviewed against the exact application behavior and reduced to the smallest set of permissions that still satisfies the operational requirement.

## Firewall

Lab rules:

- TCP/80 from `0.0.0.0/0`
- TCP/22 from `0.0.0.0/0`

HTTP exposure is intentional so the Nginx test page can be validated from the internet.

SSH exposure is temporary and intended only for this learning environment. Production improvements include:

- restricting SSH source CIDRs;
- using Identity-Aware Proxy (IAP);
- enabling OS Login;
- using private administrative access;
- removing public SSH exposure when it is no longer required.

## Public IP and HTTP

The VM uses a public IPv4 address and serves the lab page over plain HTTP. This is acceptable for a temporary demonstration page with no sensitive data.

A production web workload should normally use HTTPS, managed certificates and an appropriate load-balancing or reverse-proxy architecture.

## Credentials and repository hygiene

No Service Account key file is required for this project.

Never commit:

- private keys;
- OAuth tokens;
- API keys;
- Service Account JSON keys;
- passwords;
- billing or payment data.

Screenshots should also be reviewed before publication to avoid unnecessary personal information.
