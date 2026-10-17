# Module 83 — VPC Troubleshooting Drill

## Objective

Troubleshoot AWS VPC connectivity failures systematically by testing network configuration, instance availability, and application state.

## My Troubleshooting Method

When an EC2 instance or application becomes unreachable, I investigate in this order:

1. **Route table:** Verify that a valid route exists to the destination.
2. **Security group:** Check whether the required inbound and outbound traffic is permitted.
3. **Network ACL:** Verify that the subnet permits both requests and return traffic.
4. **EC2 instance:** Confirm the instance is running and its network interface is configured correctly.
5. **Application:** Verify that the service is running and listening on the expected port.

I record what each test proves or rules out before changing the configuration.

## Failure Drill 1 — Security Group

**Symptom:** SSH connection failed.

**Cause:** Removed the inbound TCP port 22 rule from the EC2 instance's security group.

**Recovery:** Restored the SSH rule allowing traffic from the EC2 Instance Connect Endpoint's security group.

**Verification:** Established a new SSH connection successfully.

**Lesson:** Security groups are stateful. The source of traffic coming through an Instance Connect Endpoint may be the endpoint's private IP rather than my laptop's public IP.

## Failure Drill 2 — Missing S3 Route

**Symptom:** AWS CLI request to S3 timed out.

**Cause:** Removed the private subnet route table's association with the S3 Gateway Endpoint.

**Recovery:** Reassociated the route table with the Gateway Endpoint.

**Verification:** Successfully listed the S3 bucket again.

**Lesson:** Gateway Endpoints provide private routes to supported AWS services. IAM permissions cannot fix a missing network route.

## Failure Drill 3 — Network ACL

**Environment:**

- EC2 A: `10.0.1.12`
- EC2 B: `10.0.32.16`
- Two separate private subnets

**Symptom:** TCP connection timed out.

**Cause:** The custom NACL denied outbound return traffic from EC2 B's subnet.

**Recovery:** Restored the required outbound TCP ephemeral-port access.

**Verification:** TCP connection returned exit code `0` instead of `124`.

**Additional troubleshooting:** Discovered an incorrect subnet association and corrected it.

**Extra test:** Configured outbound HTTPS and inbound ephemeral-port rules to restore S3 access through the Gateway Endpoint.

**Lesson:** NACLs are stateless. Both directions must be explicitly permitted, and subnet associations must be verified.

## Failure Drill 4 — Application Failure

**Application:** Python HTTP server on TCP port 8000.

**Initial symptom:** Connection timed out because the network configuration did not permit the connection.

**Second symptom:** Connection refused after network access was corrected.

**Cause of refusal:** No application was listening on port 8000.

**Recovery:** Restarted the Python HTTP server from a safe, empty `html` directory.

**Verification:** HTTP `200 OK` returned from EC2 B to EC2 A.

**Lesson:** A reachable EC2 instance does not guarantee application availability.

## VPC Reachability Analyzer

Tested connectivity between EC2 A and EC2 B on TCP port 8000.

**Result:** Reachable, even while the Python HTTP server was stopped.

**Lesson:** Reachability Analyzer evaluates AWS network configurations, including routes, security groups, and NACLs. It does not verify that an application is running or accepting connections.

## VPC Flow Logs

Configured logging for EC2 B's network interface:

`eni-01968cb162c58d919`

CloudWatch Log Group: `module83-flowlogs`

Observed:

- `ACCEPT` records for permitted TCP connections.
- `REJECT` records after deliberately blocking traffic.
- SSH return traffic from source port 22 to an ephemeral destination port.

**Lesson:** Flow Logs provide evidence of actual network traffic. ACCEPT does not prove application health, and REJECT does not by itself identify which rule caused the rejection.

## Common Connectivity Symptoms

| Symptom | Possible explanation |
|---|---|
| Timeout | Missing route, security filtering, dropped packets, or unresponsive destination |
| Connection refused | Destination actively rejected the connection, commonly because no service is listening |
| AccessDenied | AWS authorization rejected the request |
| HTTP 200 OK | The application successfully processed the HTTP request |

## Independent Troubleshooting Drill

**Status:** Pending next-day diagnosis.

Complete after investigating the deliberately introduced fault with notes closed.

Record:

- Initial symptom:
- First hypothesis:
- First test and result:
- Other possible causes eliminated:
- Root cause:
- Corrective action:
- Verification after recovery:

## Final Explain-It-Aloud Verification

Pending.

I must explain my AWS troubleshooting order, what each diagnostic test proves, and how to distinguish network failures from application failures.

## Cleanup

Pending completion of the independent drill.

Remove temporary Flow Logs and CloudWatch logging resources, and review the IAM role created for logging. Preserve the existing VPC environment and retained EC2 instances as planned.