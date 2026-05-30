# Lab 3.4 Compliance Policies

This directory contains Rego policies that validate Terraform plans against NIST 800-53 controls for both GCP and AWS infrastructure.

## Policy Mapping by Cloud

| Control | Cloud | File | Package |
|---------|-------|------|---------|
| SC-28 | GCP | `sc28_encryption.rego` | `compliance.sc28` |
| SC-28 | AWS | `sc28_encryption_aws.rego` | `compliance.sc28_aws` |
| AC-3 | GCP | `ac3_no_public.rego` | `compliance.ac3` |
| AC-3 | AWS | `ac3_no_public_aws.rego` | `compliance.ac3_aws` |
| CM-6 | GCP | `cm6_required_tags.rego` | `compliance.cm6` |
| CM-6 | AWS | `cm6_required_tags_aws.rego` | `compliance.cm6_aws` |

## Policies

### sc28_encryption.rego (GCP)
- **Control:** SC-28 — Encryption at Rest (GCS)
- **Severity:** high
- **Description:** Every `google_storage_bucket` must encrypt at rest with a customer-managed encryption key (CMEK).
- **Remediation:** Add an `encryption { default_kms_key_name = ... }` block referencing a `google_kms_crypto_key` you control.
- **Test file:** `tests/sc28_encryption_test.rego`

### sc28_encryption_aws.rego (AWS)
- **Control:** SC-28 — Encryption at Rest (AWS S3)
- **Severity:** high
- **Description:** Every `aws_s3_bucket` must have an `aws_s3_bucket_server_side_encryption_configuration` that references it.
- **Remediation:** Add `aws_s3_bucket_server_side_encryption_configuration { bucket = aws_s3_bucket.<name>.id ... }` for the bucket.

### ac3_no_public.rego (GCP)
- **Control:** AC-3 — Access Enforcement
- **Severity:** critical
- **Description:** GCS buckets must enforce `uniform_bucket_level_access = true` AND `public_access_prevention = "enforced"`. Firewall rules must not allow `0.0.0.0/0` on management ports (22, 3389).
- **Remediation:** Set `uniform_bucket_level_access = true` and `public_access_prevention = "enforced"`. For firewalls, narrow `source_ranges` or remove the rule.
- **Test file:** `tests/ac3_no_public_test.rego`

### ac3_no_public_aws.rego (AWS)
- **Control:** AC-3 — Access Enforcement (AWS S3 public access block)
- **Severity:** critical
- **Description:** Every `aws_s3_bucket` must have an `aws_s3_bucket_public_access_block` referencing it, with all four flags true.
- **Remediation:** Add `aws_s3_bucket_public_access_block` with all four block flags set to `true`.

### cm6_required_tags.rego (GCP)
- **Control:** CM-6 — Configuration Settings (required compliance labels)
- **Severity:** medium
- **Description:** Every taggable resource must carry the four required labels: `project`, `environment`, `managed_by`, `compliance_scope`.
- **Remediation:** Add the four required labels to the resource.
- **Test file:** `tests/cm6_required_tags_test.rego`

### cm6_required_tags_aws.rego (AWS)
- **Control:** CM-6 — Configuration Settings (AWS required tags)
- **Severity:** medium
- **Description:** Every taggable AWS resource must carry the four required tags: `Project`, `Environment`, `ManagedBy`, `ComplianceScope`.
- **Remediation:** Add the missing tags or use provider `default_tags`.

## Running Tests

```bash
opa test -v policies/
```

Expected result: `PASS: 8/8` (GCP fixtures only)

## Evaluating Against a Terraform Plan with Conftest

```bash
conftest test --policy policies --namespace compliance.sc28_aws plan.json
conftest test --policy policies --namespace compliance.ac3_aws  plan.json
conftest test --policy policies --namespace compliance.cm6_aws  plan.json
```

## Wrapper Script

`scripts/policy-gate.sh` runs all namespaces against a Terraform workspace and produces `evidence/lab-3-4/conftest-results.json`.

```bash
bash scripts/policy-gate.sh --workspace ./terraform
```
