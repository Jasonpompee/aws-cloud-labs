# IAM Policy Evaluation Notes

## Core Rule

AWS denies requests by default.

A request is allowed only when an applicable Allow exists and there is no applicable explicit Deny.

An explicit Deny always overrides an Allow.

## Simplified Evaluation Flow

1. Check for an applicable explicit Deny.
2. Evaluate organizational restrictions.
3. Evaluate resource-based policies.
4. Evaluate identity-based policies.
5. Evaluate session policies.
6. If no applicable Allow exists, the result is an implicit Deny.

## Implicit vs Explicit Deny

Implicit Deny means no matching Allow exists.

Explicit Deny means a matching policy statement contains:

```json
"Effect": "Deny"