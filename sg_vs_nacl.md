# Module 82 — Security Groups vs. Network ACLs

## Objective

Understand the difference between stateful and stateless network security controls in AWS, and troubleshoot connectivity failures caused by NACL rules.

## Security Groups

- Stateful: Automatically permit response traffic for allowed connections.
- Support Allow rules, not Deny rules.
- Apply to network interfaces.
- Can reference other security groups instead of specific IP addresses.
- Useful for controlling which applications and instances can communicate.

## Network ACLs

- Stateless: Inbound and outbound traffic are evaluated independently.
- Support both Allow and Deny rules.
- Apply at the subnet level.
- Evaluate numbered rules in ascending order, stopping at the first match.
- Default NACLs initially allow all traffic; newly created custom NACLs initially deny all traffic.

## Troubleshooting Lab

**Environment**
- EC2 instance in Private A.
- EC2 Instance Connect Endpoint in Private B.
- Custom NACL: `module82-ssh-drill-nacl`.
- EC2 security group allows SSH from the endpoint's `module81` security group.

**Problem**

SSH stopped working after applying the custom NACL with inbound SSH permitted but outbound return traffic blocked.

**Root Cause**

The NACL was stateless. Although inbound TCP port 22 was allowed, the SSH response needed to reach the client's temporary (ephemeral) port.

The outbound NACL rules did not permit that return traffic.

**Solution**

Configured the necessary NACL rules:

| Direction | Protocol | Ports | Purpose |
|---|---|---|---|
| Inbound | TCP | 22 | Allow SSH requests |
| Outbound | TCP | 1024–65535 | Allow SSH return traffic |

The outbound destination CIDR was `10.0.0.0/16`, covering the VPC.

**Verification**

SSH connectivity was successfully restored while the custom NACL remained associated with Private A.

## Security Group Reference

Verified that EC2-A's security group allows SSH from the `module81` security group rather than a specific source IP address.

This permits replacement instances using the referenced security group to connect without updating IP-based permissions.

## Security Considerations

- Prefer appropriately scoped security group rules for instance-level access.
- Restrict NACL CIDR ranges to necessary networks.
- Use an ephemeral port range appropriate for the connecting clients.
- Avoid broad Allow rules when narrower rules satisfy the requirement.

## Interview Explanation

Security groups are stateful. Return traffic for an allowed connection is automatically permitted.

NACLs are stateless. They evaluate inbound and outbound traffic separately.

During my lab, SSH failed because the custom NACL allowed inbound port 22 but blocked outbound responses. I fixed the connection by allowing outbound ephemeral ports and verified that SSH worked with the custom NACL still attached.