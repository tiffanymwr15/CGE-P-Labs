# Compliant GCS Bucket Module

A Terraform module that creates a Google Cloud Storage bucket with a security floor that consumers cannot disable.

## Controls Enforced

| NIST Family | Control | Module Enforcement |
|---|---|---|
| SC-12 | Cryptographic Key Establishment | Dedicated KMS keyring + CMEK per bucket |
| SC-13 | Use of Cryptography | AES-256 encryption via Google-managed CMEK |
| SC-28 | Protection of Information at Rest | CMEK encryption + 90-day key rotation |
| AC-3 | Access Enforcement | `uniform_bucket_level_access = true` |
| AU-11 | Audit Record Retention | Object versioning + configurable retention policy |
| CM-6 | Configuration Settings | Required labels merged on top of consumer labels |

## Usage

```hcl
module "data_bucket" {
  source = "../../modules/compliant-gcs-bucket"

  gcp_project        = "tiffanys-test-lab"
  project_label      = "cgep-lab"
  environment        = "dev"
  retention_days     = 30
  bucket_name_suffix = "dev-data-001"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| gcp_project | GCP project ID | string | n/a | yes |
| location | GCS bucket location | string | `us-central1` | no |
| kms_location | KMS keyring location (single region) | string | `us-central1` | no |
| project_label | Short project identifier | string | n/a | yes |
| environment | Deployment environment (dev, staging, prod) | string | n/a | yes |
| retention_days | Object retention in days | number | n/a | yes |
| bucket_name_suffix | Globally-unique bucket suffix | string | n/a | yes |
| labels | Optional additional labels | map(string) | `{}` | no |

## Outputs

| Name | Description |
|---|---|
| bucket_url | gs:// URL of the compliant bucket |
| bucket_self_link | Self-link of the bucket |
| kms_key_id | Resource ID of the CMEK |
| compliance_attestation | Computed map of enforced controls |
