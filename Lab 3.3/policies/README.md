# Lab 3.3 Compliance Policies

This directory contains Rego policies that validate Terraform plans against NIST 800-53 controls for GCP infrastructure.

## Policies

### sc28_encryption.rego
- **Control:** SC-28 — Encryption at Rest (GCS)
- **Severity:** high
- **Description:** Every `google_storage_bucket` must encrypt at rest with a customer-managed encryption key (CMEK).
- **Remediation:** Add an `encryption { default_kms_key_name = ... }` block referencing a `google_kms_crypto_key` you control.
- **Test file:** `tests/sc28_encryption_test.rego`
  - `test_compliant_passes` — bucket with valid CMEK passes
  - `test_noncompliant_fails` — bucket without encryption block fails

### ac3_no_public.rego
- **Control:** AC-3 — Access Enforcement
- **Severity:** critical
- **Description:** GCS buckets must enforce `uniform_bucket_level_access = true` AND `public_access_prevention = "enforced"`. Firewall rules must not allow `0.0.0.0/0` on management ports (22, 3389).
- **Remediation:** Set `uniform_bucket_level_access = true` and `public_access_prevention = "enforced"`. For firewalls, narrow `source_ranges` or remove the rule.
- **Test file:** `tests/ac3_no_public_test.rego`
  - `test_compliant_bucket_passes` — locked-down bucket passes
  - `test_public_bucket_fails` — publicly accessible bucket fails
  - `test_open_management_port_fails` — firewall open to 0.0.0.0/0 on port 22 fails

### cm6_required_tags.rego
- **Control:** CM-6 — Configuration Settings (required compliance labels)
- **Severity:** medium
- **Description:** Every taggable resource must carry the four required labels: `project`, `environment`, `managed_by`, `compliance_scope`.
- **Remediation:** Add the four required labels (`project`, `environment`, `managed_by`, `compliance_scope`) to the resource.
- **Test file:** `tests/cm6_required_tags_test.rego`
  - `test_complete_passes` — resource with all required labels passes
  - `test_partial_fails` — resource with only some labels fails
  - `test_no_labels_fail` — resource with no labels fails

## Running Tests

```bash
opa test -v policies/
```

Expected result: `PASS: 8/8`

## Evaluating Against a Terraform Plan

```bash
opa eval -d policies -i plan.json data.compliance.sc28.deny --format=pretty
opa eval -d policies -i plan.json data.compliance.ac3.deny  --format=pretty
opa eval -d policies -i plan.json data.compliance.cm6.deny  --format=pretty
```
