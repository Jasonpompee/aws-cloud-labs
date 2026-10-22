# Module 88 — Application Load Balancer (ALB)

## Objective

Build an Application Load Balancer with two EC2 web servers in separate Availability Zones. Configure listeners, target groups, health checks, and security groups. Independently verify traffic distribution, diagnose failures, and restore service.

## 1. Architecture

The infrastructure was built independently in AWS Region `us-east-1`.

### Resources

- 1 VPC
- 2 public subnets across separate Availability Zones
- 1 Internet Gateway
- Route tables with internet connectivity
- Security groups for the ALB and EC2 instances
- 2 Ubuntu EC2 instances running Apache
- 1 internet-facing Application Load Balancer
- 1 target group with both EC2 instances registered

### Traffic Flow

```text
Internet
    |
Internet Gateway
    |
Public Application Load Balancer
    |
HTTP Listener (Port 80)
    |
Target Group (HTTP Port 80)
    |
    +---- EC2 Instance A (Apache)
    |
    +---- EC2 Instance B (Apache)
```

The target group is a logical routing configuration, not another physical server. The ALB selects a registered target and connects directly to its configured application port.

## 2. Security Group Configuration

### ALB Security Group
- Allows inbound HTTP traffic on port 80 from the internet.

### EC2 Security Group
- Allows inbound HTTP traffic on port 80 from the ALB security group.
- Does not require public HTTP access from `0.0.0.0/0`.

Separating these security groups helps prevent clients from bypassing the ALB and accessing the application directly.

## 3. Target Group and Health Checks

**Target type:** Instances

**Health check configuration:** AWS defaults, as reported during the lab.

| Setting | Value |
|---|---|
| Protocol | HTTP |
| Health check path | `/` |
| Port | Traffic port (80) |
| Interval | 30 seconds |
| Timeout | 5 seconds |
| Healthy threshold | 5 |
| Unhealthy threshold | 2 |
| Success code | 200 |

### Configuration Reasoning

The default settings were retained because they are reasonable starting values for a simple Apache application.

- **HTTP:** Appropriate