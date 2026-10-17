# Module 85 — EBS and Instance Storage

## Objective
Learn to manage Amazon EBS volumes, verify data persistence, create snapshots, restore lost data, and identify orphaned storage.

## EBS Volume Setup
- Created and attached a 10 GiB EBS volume to an Ubuntu EC2 instance.
- Identified the block device using `lsblk`.
- Created an ext4 filesystem using `mkfs.ext4`.
- Created a mount point at `/mnt/ebs-data`.
- Mounted the filesystem and created test files.
- Practiced Linux ownership management using `chown`.

## Persistence Verification
- Stopped and restarted the EC2 instance.
- Verified the files remained available.
- Unmounted, detached, and reattached the EBS volume.
- Remounted the existing filesystem without formatting.
- Confirmed the original files remained intact.

## Snapshot and Recovery
1. Created an EBS snapshot of the original volume.
2. Waited until the snapshot completed.
3. Created a replacement volume from that snapshot.
4. Attached the restored volume to EC2.
5. Mounted the existing filesystem without formatting.
6. Verified that the original data was recoverable.
7. Independently recovered snapshot data on a different EC2 instance.

## Failure Drill — Orphaned EBS Volume
- Configured an attached data volume with Delete on termination set to No.
- Terminated the recovery EC2 instance.
- Confirmed the data volume survived.
- Deleted the orphaned volume after the test.

**Lesson:** An EBS volume can continue generating storage charges after its EC2 instance is terminated.

## Key Lessons
- EBS volumes persist independently of the EC2 instance lifecycle when they are retained.
- A snapshot provides a point-in-time recovery mechanism.
- Existing filesystems should not be reformatted during restoration.
- Filesystem permissions determine whether ordinary users can write data.
- Unattached EBS volumes and retained snapshots can incur storage costs.
- Instance store is temporary storage, unlike persistent EBS volumes.