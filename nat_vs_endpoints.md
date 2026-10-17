# Module 81 — NAT Gateway vs. VPC Endpoints

## Objective
Understand how private AWS resources access the internet and AWS services, and compare networking costs.

## Architecture
- Custom VPC spanning two Availability Zones
- Two public and two private subnets
- Internet Gateway
- Regional NAT Gateway (removed after testing)
- Private EC2 instance
- S3 Gateway Endpoint
- EC2 IAM role with S3 ListBucket and GetObject permissions

## Verification
1. EC2 successfully accessed Google through the NAT Gateway.
2. Created an S3 Gateway Endpoint.
3. Associated the private route table with the endpoint.
4. Removed the NAT default route.
5. S3 access succeeded with exit code 0.
6. Google access timed out without the NAT route.

## Troubleshooting
**Problem:** S3 access initially hung after the NAT route was removed.

**Root cause:** The S3 Gateway Endpoint was not associated with the private route table.

**Solution:** Associated the correct route table. AWS automatically added the S3 prefix-list route.

## Monthly Cost Comparison

Example assumptions: 730 hours, 100 GB processed, two active Availability Zones.

| Resource | Estimated monthly cost |
|---|---:|
| Regional NAT Gateway | $70.20 |
| One Interface Endpoint across two AZs | $15.60 |
| S3 Gateway Endpoint | $0 |
| DynamoDB Gateway Endpoint | $0 |

Estimates exclude other applicable data transfer charges and assume the example pricing rates discussed in the lesson.

## Architecture Recommendation
For workloads that only access S3 and DynamoDB, use Gateway Endpoints to avoid unnecessary NAT Gateway charges.

For workloads requiring external public APIs, provide an appropriate internet egress path, such as a NAT Gateway for private instances.

Interface Endpoints may reduce costs for certain AWS service access patterns, but each endpoint adds charges and configuration overhead.