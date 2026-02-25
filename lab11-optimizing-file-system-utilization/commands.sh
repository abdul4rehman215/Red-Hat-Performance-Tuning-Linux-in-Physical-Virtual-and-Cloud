#!/bin/bash
# Lab 11 - Optimizing File System Utilization
# Commands Executed During Lab (Sequential / No Explanations)

# -------------------------------
# Task 1.1: Review Current Mounts
# -------------------------------
mount | grep -E "(ext4|xfs|btrfs)"
cat /proc/mounts | grep -E "(ext4|xfs|btrfs)"
df -h

# -----------------------------------------
# Task 1.1: Create Test Directory + atime
# -----------------------------------------
sudo mkdir -p /opt/fstest
cd /opt/fstest
echo "Test file for access time monitoring" > testfile.txt
stat testfile.txt

# -------------------------------------------------------
# Task 1.2: Create Loopback EXT4 FS + Baseline Benchmark
# -------------------------------------------------------
sudo dd if=/dev/zero of=/opt/testfs.img bs=1M count=1024
sudo losetup /dev/loop0 /opt/testfs.img
sudo losetup -a | head -3
sudo mkfs.ext4 /dev/loop0
sudo mkdir -p /mnt/optimized-fs

sudo mount /dev/loop0 /mnt/optimized-fs

sudo nano /opt/fstest/baseline_test.sh
sudo chmod +x /opt/fstest/baseline_test.sh
/opt/fstest/baseline_test.sh

# -----------------------------------------
# Task 1.2: Remount with noatime/nodiratime
# -----------------------------------------
sudo umount /mnt/optimized-fs
sudo mount -o noatime,nodiratime /dev/loop0 /mnt/optimized-fs
mount | grep optimized-fs

sudo nano /opt/fstest/optimized_test.sh
sudo chmod +x /opt/fstest/optimized_test.sh
/opt/fstest/optimized_test.sh

# --------------------------------------------------------
# Task 1.3: Attempt Additional EXT4 Options + Fix + Retest
# --------------------------------------------------------
sudo umount /mnt/optimized-fs
sudo mount -o noatime,nodiratime,data=writeback,barrier=0,nobh /dev/loop0 /mnt/optimized-fs
sudo mount -o noatime,nodiratime,data=writeback /dev/loop0 /mnt/optimized-fs
mount | grep optimized-fs

sudo nano /opt/fstest/comprehensive_test.sh
sudo chmod +x /opt/fstest/comprehensive_test.sh
/opt/fstest/comprehensive_test.sh

# ----------------------------------------------
# Task 2.1: EXT4 Tuned FS (mkfs + mount + queue)
# ----------------------------------------------
sudo dd if=/dev/zero of=/opt/ext4_tuned.img bs=1M count=1024
sudo losetup /dev/loop1 /opt/ext4_tuned.img
sudo mkfs.ext4 -b 4096 -E stride=32,stripe-width=64 -O ^has_journal /dev/loop1
sudo mkdir -p /mnt/ext4-tuned

sudo mount -o noatime,nodiratime,data=writeback,commit=60 /dev/loop1 /mnt/ext4-tuned
mount | grep ext4-tuned

echo 4096 | sudo tee /sys/block/loop1/queue/read_ahead_kb
echo deadline | sudo tee /sys/block/loop1/queue/scheduler
cat /sys/block/loop1/queue/read_ahead_kb
cat /sys/block/loop1/queue/scheduler

# ----------------------------------------------
# Task 2.2: XFS Tuned FS (mkfs + mount + sysfs)
# ----------------------------------------------
sudo dd if=/dev/zero of=/opt/xfs_tuned.img bs=1M count=1024
sudo losetup /dev/loop2 /opt/xfs_tuned.img
sudo mkfs.xfs -b size=4096 -d agcount=4 -l size=64m /dev/loop2
sudo mkdir -p /mnt/xfs-tuned

sudo mount -o noatime,nodiratime,logbufs=8,logbsize=256k,largeio,inode64 /dev/loop2 /mnt/xfs-tuned
mount | grep xfs-tuned

echo 65536 | sudo tee /sys/fs/xfs/loop2/log_recovery_delay
echo 1 | sudo tee /sys/fs/xfs/loop2/irix_sgid_inherit
echo 1 | sudo tee /sys/fs/xfs/loop2/irix_symlink_mode
ls -la /sys/fs/xfs/loop2/ | head

# ------------------------------------------------
# Task 2.3: Btrfs Tuned FS (mkfs + mount + btrfs)
# ------------------------------------------------
sudo dd if=/dev/zero of=/opt/btrfs_tuned.img bs=1M count=1024
sudo losetup /dev/loop3 /opt/btrfs_tuned.img
sudo mkfs.btrfs -f /dev/loop3
sudo mkdir -p /mnt/btrfs-tuned

sudo mount -o noatime,nodiratime,compress=lzo,space_cache=v2,commit=60 /dev/loop3 /mnt/btrfs-tuned
mount | grep btrfs-tuned

sudo btrfs filesystem defragment -r -v -clzo /mnt/btrfs-tuned
sudo btrfs filesystem show /mnt/btrfs-tuned
sudo btrfs filesystem usage /mnt/btrfs-tuned

# ---------------------------------------------
# Task 3.1: Standardized Benchmarking Script(s)
# ---------------------------------------------
sudo nano /opt/fstest/filesystem_benchmark.sh
sudo chmod +x /opt/fstest/filesystem_benchmark.sh
/opt/fstest/filesystem_benchmark.sh | tee /opt/fstest/benchmark_results.txt

# ---------------------------------------
# Task 3.2: I/O Monitoring (iostat -x ...)
# ---------------------------------------
sudo nano /opt/fstest/io_monitor.sh
sudo chmod +x /opt/fstest/io_monitor.sh
/opt/fstest/io_monitor.sh

echo "=== EXT4 I/O Statistics ==="
tail -5 /tmp/iostat_EXT4.log
echo "=== XFS I/O Statistics ==="
tail -5 /tmp/iostat_XFS.log
echo "=== BTRFS I/O Statistics ==="
tail -5 /tmp/iostat_BTRFS.log

# --------------------------------------------
# Task 3.3: CPU + Memory Monitoring + Report
# --------------------------------------------
sudo nano /opt/fstest/resource_monitor.sh
sudo chmod +x /opt/fstest/resource_monitor.sh
/opt/fstest/resource_monitor.sh

sudo nano /opt/fstest/generate_report.sh
sudo chmod +x /opt/fstest/generate_report.sh
/opt/fstest/generate_report.sh | tee /opt/fstest/performance_report.txt

# -------------------------
# Troubleshooting Commands
# -------------------------
sudo losetup -a
sudo chmod 755 /mnt/ext4-tuned /mnt/xfs-tuned /mnt/btrfs-tuned
ls -Z /mnt/ 2>/dev/null | head
sync
echo 3 | sudo tee /proc/sys/vm/drop_caches
iostat -x 1 1

# -----------
# Lab Cleanup
# -----------
sudo umount /mnt/optimized-fs 2>/dev/null
sudo umount /mnt/ext4-tuned 2>/dev/null
sudo umount /mnt/xfs-tuned 2>/dev/null
sudo umount /mnt/btrfs-tuned 2>/dev/null

sudo losetup -d /dev/loop0 2>/dev/null
sudo losetup -d /dev/loop1 2>/dev/null
sudo losetup -d /dev/loop2 2>/dev/null
sudo losetup -d /dev/loop3 2>/dev/null

sudo rm -f /opt/testfs.img /opt/ext4_tuned.img /opt/xfs_tuned.img /opt/btrfs_tuned.img
sudo rm -f /tmp/iostat_*.log /tmp/cpu_*.log /tmp/memory_*.log
echo "Lab results saved in /opt/fstest/ directory"
ls -la /opt/fstest/
