# Troubleshooting

## Storage upload returned HTTP 403

During the backup test, the VM authenticated correctly as:

`cloud-lab-backup@gcp-cloud-infrastructure-lab.iam.gserviceaccount.com`

However, the command below returned HTTP 403:

```bash
gcloud storage cp ~/backups/nginx-backup.tar.gz gs://carleandro-gcp-cloud-lab-2026/backups/
```

The error indicated missing `storage.objects.get` access.

## Root cause

The Service Account initially had the role:

`roles/storage.objectCreator`

That role is intentionally restrictive and is focused on object creation. The CLI workflow being used in this lab required additional object permissions for its operation and validation steps.

## Resolution

The bucket-level IAM binding was adjusted to:

`roles/storage.objectUser`

Command used:

```bash
gcloud storage buckets add-iam-policy-binding gs://carleandro-gcp-cloud-lab-2026 --member="serviceAccount:cloud-lab-backup@gcp-cloud-infrastructure-lab.iam.gserviceaccount.com" --role="roles/storage.objectUser"
```

After the change, the backup upload and object listing succeeded.

## Lesson learned

IAM errors should be solved by understanding which permission is missing and assigning the smallest role that satisfies the actual operational requirement, rather than granting broad project-level administrative access.

---

## Backup file disappeared after VM restart

The first backup was created under `/tmp`.

After stopping and starting the VM, the file was no longer available. The backup path was changed to:

```text
~/backups/
```

This provided a persistent location on the VM boot disk for subsequent tests.

## Lesson learned

Temporary directories should not be treated as persistent application storage. Operational scripts should use an explicit persistent path when data needs to survive service or instance lifecycle events.
