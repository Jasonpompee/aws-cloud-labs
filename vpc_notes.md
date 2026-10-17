# Module 80 — VPC I: Network Configuration and Troubleshooting

## Objective
Build and troubleshoot a VPC across two Availability Zones with public and private subnets.

## Network Configuration

- **VPC:** `my-joke-app-vpc`
- **CIDR:** `10.0.0.0/16`
- **Region:** `us-east-1`
- **Public subnets:** 2
- **Private subnets:** 2
- **Internet Gateway:** Attached to VPC
- **NAT Gateway:** Regional NAT Gateway
- **Route tables:** `public-joke-rt` and `joke-private-rt`

## Routing

| Route table | Destination | Target |
|---|---|---|
| Public | `10.0.0.0/16` | local |
| Public | `0.0.0.0/0` | Internet Gateway |
| Private | `10.0.0.0/16` | local |
| Private | `0.0.0.0/0` | Regional NAT Gateway |

Public instances with public IP addresses can access the internet through the Internet Gateway.

Private instances can initiate outbound internet connections through the Regional NAT Gateway, which uses its own routing to the Internet Gateway.

Instances inside the VPC communicate using the local route, provided their security rules allow the traffic.

## Subnet IP Addressing

Each `/27` subnet provides 32 IPv4 addresses. AWS reserves five, leaving 27 addresses available for resources.

The reserved addresses are the network address, VPC router address, DNS-reserved address, AWS future-use address, and final subnet address.

## Connectivity Verification

- Successfully connected to both private EC2 instances through EC2 Instance Connect Endpoint.
- Verified outbound HTTPS connectivity from a private EC2 instance with HTTP 200.
- Launched a temporary public EC2 instance (`10.0.0.22`).
- Verified public internet connectivity with HTTP 200.

## Troubleshooting Drill

**Problem:** Removed the Internet Gateway default route from the public route table.

**Observation:** The public test EC2 could no longer reach the external website.

**Cause:** The subnet had no matching route for public internet destinations.

**Resolution:** Restored `0.0.0.0/0 → IGW`, returning internet connectivity.

**Lesson:** A public IP and permissive security group alone cannot provide internet access without valid routing.

## Cost and Cleanup

The temporary test instance and project networking resources were deleted after testing, as reported during cleanup.

The Regional NAT Gateway was also deleted to avoid continued gateway charges.

## Independent Network Diagram

*Add my own diagram showing the VPC, two Availability Zones, four subnets, public and private route tables, Internet Gateway, Regional NAT Gateway, and traffic directions.*
