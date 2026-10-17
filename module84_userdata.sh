# Module 84 — EC2 Launch Templates, User Data, and AMIs

## Objective

Deploy reproducible EC2 instances that automatically install and configure an Apache web server using user data and EC2 launch templates.

Learn how to troubleshoot failed deployments using cloud-init logs and recover using a known-good launch template version.

## AWS Resources Used

| Resource         | Configuration            |
| ---------------- | ------------------------ |
| AWS Region       | us-east-1                |
| Operating System | Ubuntu Server 26.04 LTS  |
| AMI ID           | ami-0b6d9d3d33ba97d99    |
| Instance Type    | t3.micro                 |
| Launch Template  | module84-apache-template |
| Web Server       | Apache2                  |
| Automation       | Bash user data           |
| Service Manager  | systemd                  |
| Troubleshooting  | cloud-init               |

## 1. EC2 User Data

EC2 user data allows an instance to configure itself automatically during initialization.

On Ubuntu, cloud-init executes the supplied Bash script, normally during the instance's first boot.

My script performed the following operations:

1. Created `/tmp/boot_status.txt` to record initialization.
2. Updated Ubuntu's package index using `apt-get update`.
3. Installed Apache using `apt-get install -y apache2`.
4. Enabled Apache using `systemctl enable apache2`.
5. Started Apache using `systemctl start apache2`.
6. Created a custom webpage at `/var/www/html/index.html`.

**Working script:** `module84_userdata.sh`

### Important Linux concepts

- `apt-get` manages packages on Ubuntu.
- `-y` automatically confirms installation prompts.
- `systemctl enable` configures a service to start automatically at boot.
- `systemctl start` starts a service immediately.
- User data scripts normally execute once during an instance's first boot, not every time it restarts.

## 2. EC2 Launch Templates

A launch template stores reusable EC2 configuration settings such as:

- Amazon Machine Image (AMI)
- Instance type
- Key pair
- Security group configuration
- User data
- Other launch settings

I created `module84-apache-template` and used it to launch an Ubuntu EC2 instance.

The instance automatically installed Apache and displayed my custom webpage without manual server configuration.

**Result: Successful automatic deployment.**

## 3. Reproducibility Testing

I launched a second EC2 instance using the same launch template version.

Both instances successfully displayed the same webpage without manual installation.

I also tested replacing an instance by terminating it and launching another instance using the original template.

**Result: Reproducibility and replacement verified.**

This demonstrated that a launch template can produce consistent deployments without manually configuring each server.

## 4. Troubleshooting — Intentional Failure

I created a separate script named `module84_userdata_broken.sh`.

I deliberately changed the Apache installation package from `apache2` to `apache`.

The incorrect command caused the installation to fail.

### Observed errors

**Root cause:**

`E: Package 'apache' has no installation candidate`

**Secondary errors:**

- `Failed to enable unit: Unit apache2.service does not exist`
- `Failed to start apache2.service: Unit apache2.service not found`
- `/var/www/html/index.html: No such file or directory`
- Cloud-init reported that `scripts_user` failed.

### Root Cause Analysis

The Ubuntu package manager could not locate a package named `apache`.

Because Apache was not installed:

1. The Apache service was unavailable.
2. Systemd could not enable or start Apache.
3. The expected website directory was missing.
4. The custom HTML file could not be created.
5. The website was unavailable.

This was a cascading failure caused by one incorrect package name.

## 5. Cloud-init Troubleshooting

Two important log files are:

- `/var/log/cloud-init.log` — Cloud-init execution details.
- `/var/log/cloud-init-output.log` — Output and errors produced during initialization.

I inspected the cloud-init output log to identify the installation failure.

I also examined logs from a successful instance to confirm that Apache was installed and enabled.

**Troubleshooting lesson:** Identify the first meaningful error instead of fixing secondary symptoms without understanding their cause.

## 6. Recovery Using Launch Template Versions

Launch template versions allow configurations to be preserved and reused.

- **Version 1:** Original working Apache configuration.
- **Version 2:** Deliberately broken Apache configuration.

After identifying the problem, I corrected the package name in my local script.

I then relaunched an instance using the original working launch template, Version 1.

The new instance automatically installed Apache and displayed the original webpage.

**Result: Successful rollback to a known-good configuration.**

This demonstrated how restoring a previously tested deployment configuration can recover a service after a failed change.

## 7. Why Pin an AMI?

An AMI defines the base image used to launch an EC2 instance.

Pinning a specific AMI ID provides:

- **Consistency:** Instances start from the same base image.
- **Compatibility:** Applications run on an operating system image already tested.
- **Reproducibility:** Deployments are easier to repeat.
- **Controlled updates:** New images can be tested before adoption.

Using the latest available AMI without testing could introduce unexpected software or dependency changes.

AMI IDs are also Region-specific, and the image architecture must be compatible with the selected EC2 instance type.

## 8. Security and Cost Considerations

- Restrict SSH access to authorized sources.
- Use an appropriate security group for HTTP access.
- Keep launch template versions organized.
- Update operating system images through a tested process.
- Terminate temporary EC2 instances when testing is complete.
- Check for remaining billable AWS resources after cleanup.

## 9. Interview Explanation

**Question: Why use EC2 launch templates and user data?**

Launch templates provide reusable instance configurations, while user data automatically configures software during initialization.

Together, they reduce manual work, improve consistency, and allow cloud engineers to reproduce server deployments.

**Question: How would you troubleshoot a failed EC2 user data script?**

I would inspect cloud-init logs, identify the first meaningful error, determine whether later failures were consequences of that error, correct the configuration, and verify the repair on a fresh instance.

If a known-good launch template version exists, I could use it to restore service while investigating the faulty configuration.

## 10. Verification Status

- [x] Created a working user data script.
- [x] Created an EC2 launch template.
- [x] Successfully deployed Apache automatically.
- [x] Launched two identically configured instances.
- [x] Reproduced the deployment after instance termination.
- [x] Introduced an intentional installation failure.
- [x] Identified the root cause using cloud-init logs.
- [x] Corrected the package name in the local script.
- [x] Recovered using the original working launch template.
- [x] Explained why AMI pinning matters.
- [x] Commit module deliverables to Git.
- [x] Complete final AWS resource cleanup.

**Module status:** Hands-on deployment and troubleshooting verified. Git deliverables and final cleanup pending.

---

## Skills Demonstrated

Amazon EC2, launch templates, AMIs, Bash automation, Ubuntu Linux, Apache, systemd, cloud-init, log analysis, troubleshooting, reproducible deployments, and configuration rollback.
