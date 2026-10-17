# Module 78 — Cross-Account Access Design

## Objective
Understand how an IAM identity in one AWS account can securely access resources in another AWS account using IAM roles and temporary STS credentials.

## Account A — Management Account

Account A contains the IAM user requesting access to resources in Account B.

The IAM user needs an identity-based permissions policy allowing `sts:AssumeRole` on the specific IAM role in Account B.

Account A does not need permanent IAM access keys created in Account B.

## Account B — Workload Account

Account B owns the S3 bucket and the cross-account IAM role.

The role requires two policies:

- **Trust policy:** Allows the authorized IAM identity from Account A to assume the role.
- **Permissions policy:** Allows the assumed role to perform specific actions on resources, such as `s3:GetObject`.

The role should follow the principle of least privilege.

## Cross-Account Access Flow

1. An IAM user in Account A requests to assume an IAM role in Account B.
2. The IAM user needs `sts:AssumeRole` permission.
3. Account B's role trust policy must authorize the requesting identity.
4. AWS STS issues temporary security credentials after the request is authorized.
5. The caller uses those temporary credentials to access resources in Account B.
6. AWS evaluates the assumed role's permissions and other applicable policies before allowing access to S3.

## ExternalId and Third-Party Access

An ExternalId is an additional condition used in cross-account trust policies, particularly when trusting third-party services.

It helps prevent the confused deputy problem, where a service could be tricked into accessing one customer's AWS resources on behalf of another customer.

An ExternalId is not a password or secret.

If the trust policy requires a specific ExternalId and the caller provides the wrong value or omits it, STS denies the role assumption.

## Security Benefits

- Temporary credentials automatically expire.
- Long-term access keys do not need to be distributed across AWS accounts.
- IAM roles provide centralized control over permissions.
- Trust policies determine which identities can assume roles.
- Least-privilege permissions limit access to required resources.

## Troubleshooting

### Scenario 1 — Incorrect Trust Policy

**Problem:** Account A has `sts:AssumeRole` permission, but Account B trusts Account C.

**Result:** The AssumeRole request is denied.

**Fix:** Correct Account B's trust policy to authorize the intended identity from Account A.

### Scenario 2 — Missing S3 Permission

**Problem:** Account A successfully assumes the role, but the role only allows `s3:ListBucket`.

**Result:** Downloading an object fails because the role lacks `s3:GetObject`.

**Fix:** Add the required `s3:GetObject` permission for the appropriate S3 objects.

### Scenario 3 — Incorrect ExternalId

**Problem:** The role requires ExternalId `A123`, but the caller provides `B456`.

**Result:** STS denies the AssumeRole request.

**Fix:** Ensure the authorized third-party service supplies the correct ExternalId.

## Architecture Design

Account A (Management Account)
- IAM user
- Permission to call sts:AssumeRole

↓

AWS STS validates the role-assumption request

↓

Account B (Workload Account)
- IAM role
- Trust policy authorizing Account A's identity
- Permissions policy allowing s3:GetObject
- S3 bucket

↓

Temporary credentials are used to download authorized S3 objects.

## Cost and Cleanup

This is a design-only exercise. No AWS resources were deployed, so no cleanup is required.

## Verification Status

- Cross-account permission requirements reviewed.
- STS temporary credentials explained.
- ExternalId failure behavior explained.
- Missing S3 permission failure diagnosed.
- Independent design diagram and final verification still pending.