# Security Notes

## IAM

The lab uses a dedicated Service Account for VM backup operations:

`cloud-lab-backup@gcp-cloud-infrastructure-lab.iam.gserviceaccount.com`

The purpose is to avoid using a personal identity for workload access to Cloud Storage.

## Least privilege

The first permission model used `roles/storage.objectCreator`. During validation, the `gcloud storage` workflow required additional object permissions for the test scenario, so the lab was adjusted to `roles/storage.objectUser` at the bucket level.

For production, permissions should be reviewed against the exact application behavior and reduced as much as operationally possible.

## Firewall

Lab rules:

- TCP/80 from `0.0.0.0/0`
- TCP/22 from `0.0.0.0/0`

HTTP exposure is intentional so the Nginx test page can be validated from the internet.

SSH exposure is acceptable only for this temporary lab. Production options include:

- restricting source CIDRs;
- Identity-Aware Proxy (IAP);
- OS Login;
- bastion hosts;
- private administrative access.

## Credentials

No Service Account key file is required for this project. The VM uses its attached Service Account identity.

Secrets, credentials, private keys and tokens must never be committed to this repository.
