
# Module 86 — AWS Systems Manager Fundamentals

**Date:** October 18, 2026  
**Region:** us-east-1  
**Status:** Hands-on labs completed; final module requirements pending.

## 1. Objective

Learn to securely manage EC2 instances using AWS Systems Manager without requiring SSH keys, inbound port 22, or a bastion host.

## 2. Systems Manager Architecture

Session Manager provides secure remote access to EC2 instances.

Requirements:
- SSM Agent installed and running
- IAM instance profile with appropriate permissions
- Outbound HTTPS connectivity on port 443
- AWS Systems Manager endpoints reachable
- IAM permissions for the user starting the session

The IAM role used in this lab was `module86-ssm-ec2-role`, with the managed policy `AmazonSSMManagedInstanceCore`.

An instance profile allows EC2 to use the permissions associated with an IAM role.

## 3. Session Manager Lab

Launched an Ubuntu EC2 instance and connected using Session Manager.

Configuration:
- Ubuntu Server AMI
- t3.micro instance
- No SSH key pair
- No inbound security group rules
- Outbound HTTPS access
- SSM IAM instance profile attached

Successfully opened a Linux terminal through Session Manager without SSH.

### Troubleshooting: Session Manager Connection Failure

**Problem:** EC2 was not registering as an online Systems Manager managed node.

**Root cause:** The outbound security group allowed HTTP port 80 instead of HTTPS port 443.

**Solution:** Corrected the outbound security group rules.

**Verification:** Session Manager connected successfully.

Important distinction:
- TCP 22: SSH
- TCP 80: HTTP
- TCP 443: HTTPS

SSM Agent initiates outbound HTTPS connections. Inbound port 443 is not required.

Useful connectivity test:

    nc -vz ssmmessages.us-east-1.amazonaws.com 443

## 4. AWS CLI Installation on Ubuntu

The AWS CLI was initially unavailable.

**Error:** `aws: not found`

Attempted to install AWS CLI v2.

**Second error:** Missing `unzip` dependency.

Installed the missing Ubuntu package and successfully installed AWS CLI v2.

The EC2 IAM role provided AWS credentials automatically, so manually configuring access keys was unnecessary.

## 5. Parameter Store

AWS Systems Manager Parameter Store stores configuration values outside application source code.

### String Parameter

Name: `/module86/app/environment`  
Type: String  
Value: `development`

Successfully retrieved this parameter from EC2 using the AWS CLI.

### SecureString Parameter

Name: `/module86/app/demo-api-key`  
Type: SecureString  
Encryption: AWS KMS using the AWS-managed `aws/ssm` key  
Value: Synthetic demonstration key only

Retrieved the encrypted value first.

Then used `--with-decryption` to retrieve the original demonstration value.

### IAM Permissions

Configured parameter-read permissions on the EC2 IAM role.

Used resource-specific parameter ARNs rather than broad wildcard access.

Key lesson:

IAM permissions should grant only the actions and resources that an application requires.

SecureString values use AWS KMS encryption. Additional KMS permissions may be required when using customer-managed encryption keys.

## 6. CloudWatch Session Logging

Created CloudWatch Logs log group:

`/aws/ssm/module86-session-logs`

Retention: 3 days

Also created a custom Session Manager document named:

`Module86-SessionLogging`

Purpose: Configure Session Manager logging without unnecessarily changing settings for unrelated sessions.

### Troubleshooting: Missing Session Logs

**Problem:** Session Manager connections succeeded, but no logs appeared in CloudWatch.

Investigated:
- CloudWatch Logs permissions
- IAM resource ARNs
- Session Manager preferences
- Log group configuration

Discovered that the initial IAM policy incorrectly referenced an EC2 instance ARN instead of CloudWatch Logs resources.

Corrected the IAM resource configuration.

Also discovered that CloudWatch logging was not enabled in the relevant Session Manager preferences.

Enabled CloudWatch logging and successfully verified log delivery.

### Verified Result

CloudWatch recorded:
- AWS Region
- EC2 instance ID
- IAM user identity
- Session ID
- Session operating-system user
- Terminal command and output

Test command:

    echo this the final test

CloudWatch successfully recorded the command and its output.

### Security Lesson

The EC2 IAM role needs appropriate CloudWatch Logs write permissions, and Session Manager logging must be enabled.

Session transcripts can contain sensitive output. Avoid printing credentials or secrets in recorded sessions.

## 7. Independent Rebuild

Independently launched a new Ubuntu EC2 instance with:

- No SSH key pair
- No inbound security group rules
- An SSM-enabled IAM role

Successfully connected using Session Manager.

This verified that SSH was not necessary for remote instance management.

## 8. IAM Failure and Recovery Drill

**Failure introduced:** Detached the EC2 IAM instance profile.

**Observed behavior:** A new Session Manager connection failed.

**Recovery:** Reattached the original SSM IAM role.

**Verification:** A new Session Manager connection succeeded.

### Root Cause Explanation

SSM Agent requires valid IAM credentials to communicate with AWS Systems Manager.

Without an appropriate instance profile, the agent cannot maintain the necessary authorized communication.

The failure demonstrated an IAM dependency rather than an intentionally introduced networking problem.

## 9. EC2 Launch Template

Created launch template:

`module86-ssm-template`

Configuration included:
- Ubuntu Server
- t3.micro
- SSM instance profile
- No SSH key pair
- Security group without inbound rules

Purpose: Make it easier to launch EC2 instances that can be managed securely through Session Manager.

## 10. Key Lessons

1. Session Manager allows EC2 access without SSH keys or inbound SSH ports.
2. SSM Agent needs IAM permissions and network connectivity.
3. Instance profiles make IAM roles available to EC2.
4. Parameter Store separates application configuration from source code.
5. SecureString uses AWS KMS to encrypt sensitive parameter values.
6. CloudWatch can record Session Manager terminal activity.
7. IAM permissions must reference the correct resource types.
8. CloudWatch logging requires both permissions and logging configuration.
9. Troubleshooting should distinguish IAM failures from network failures.
10. Independent rebuilding confirms practical understanding.

## 11. Operational Benefits

Session Manager is useful for Cloud Operations and Cloud Support Engineers because it:

- Reduces reliance on SSH key management
- Avoids exposing SSH ports
- Supports centralized access through AWS IAM
- Integrates with CloudWatch Logs for session auditing
- Simplifies administration of private EC2 instances when the necessary network connectivity is available

## 12. Remaining Module Requirements

- Inventory and Patch Manager awareness
- Final explain-it-aloud assessment
- AWS resource cleanup and cost verification

Module 86 will be considered complete after these remaining requirements are verified.
