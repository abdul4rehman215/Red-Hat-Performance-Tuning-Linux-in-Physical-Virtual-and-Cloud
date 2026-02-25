#!/bin/bash
# Lab 10: Disk I/O Performance Tuning (Ubuntu 20.04)
# Full commands executed (as per lab text) in sequential order.

# ------------------------------------------------------------
# Task 1: Monitor Disk Usage with iostat
# ------------------------------------------------------------

# Check if iostat is available
which iostat

# Update + install sysstat (if needed)
sudo apt update
sudo apt install -y sysstat

# Verify sysstat/iostat version
iostat -V

# Basic disk statistics
iostat

# Extended disk statistics
iostat -x

# Real-time extended disk stats (every 2 sec, 5 iterations)
iostat -x 2 5

# ------------------------------------------------------------
# Identify available disk devices
# ------------------------------------------------------------

# List block devices
lsblk

# Display disk partition information
sudo fdisk -l

# Check mounted filesystems
df -h

# Identify disk device nodes (SCSI/VirtIO/NVMe)
ls -la /dev/sd* /dev/vd* /dev/nvme* 2>/dev/null

# ------------------------------------------------------------
# Generate Disk I/O Load for Testing
# ------------------------------------------------------------

# Create test directory and move into it
mkdir -p /tmp/iotest
cd /tmp/iotest
pwd

# Write-intensive workload (direct I/O)
dd if=/dev/zero of=testfile1 bs=1M count=1000 oflag=direct

# Monitor I/O during load (run in another terminal)
iostat -x 1
# (Stop with Ctrl+C)

# Read-intensive workload (direct I/O)
dd if=testfile1 of=/dev/null bs=1M iflag=direct

# Cleanup test file
rm -f /tmp/iotest/testfile1

# ------------------------------------------------------------
# Task 2: Change Disk I/O Scheduler Using Echo Commands
# ------------------------------------------------------------

# Check scheduler (sda attempt - fails on NVMe)
cat /sys/block/sda/queue/scheduler

# Check scheduler for NVMe disk
cat /sys/block/nvme0n1/queue/scheduler

# Change scheduler (incorrect sda path - shows error)
echo deadline | sudo tee /sys/block/sda/queue/scheduler

# Set scheduler on correct NVMe device
echo mq-deadline | sudo tee /sys/block/nvme0n1/queue/scheduler

# Verify scheduler
cat /sys/block/nvme0n1/queue/scheduler

# Re-apply mq-deadline (as per lab)
echo mq-deadline | sudo tee /sys/block/nvme0n1/queue/scheduler

# Attempt bfq (expected invalid argument on this NVMe/kernel)
echo bfq | sudo tee /sys/block/nvme0n1/queue/scheduler

# ------------------------------------------------------------
# Make Scheduler Changes Persistent (rc.local + udev explored)
# ------------------------------------------------------------

# Create / edit rc.local
sudo nano /etc/rc.local

# Make rc.local executable
sudo chmod +x /etc/rc.local

# Create udev rules file
sudo nano /etc/udev/rules.d/60-ioscheduler.rules

# ------------------------------------------------------------
# Task 3: Test Disk Performance and Choose the Best Scheduler
# ------------------------------------------------------------

# Create performance testing script
nano disk_performance_test.sh

# Make it executable
chmod +x disk_performance_test.sh

# Install fio (if needed)
sudo apt install -y fio

# Install hdparm (if needed)
sudo apt install -y hdparm

# Run disk performance test script
./disk_performance_test.sh

# ------------------------------------------------------------
# Run individual fio tests (corrected single-line commands)
# ------------------------------------------------------------

# Random read
fio --name=random-read --ioengine=libaio --iodepth=16 --rw=randread --bs=4k --direct=1 --size=1G --numjobs=4 --filename=/tmp/iotest/fio-test --group_reporting --runtime=20 --time_based

# Random write
fio --name=random-write --ioengine=libaio --iodepth=16 --rw=randwrite --bs=4k --direct=1 --size=1G --numjobs=4 --filename=/tmp/iotest/fio-test --group_reporting --runtime=20 --time_based

# Sequential read
fio --name=sequential-read --ioengine=libaio --iodepth=1 --rw=read --bs=1M --direct=1 --size=2G --numjobs=1 --filename=/tmp/iotest/fio-test --group_reporting

# Sequential write
fio --name=sequential-write --ioengine=libaio --iodepth=1 --rw=write --bs=1M --direct=1 --size=2G --numjobs=1 --filename=/tmp/iotest/fio-test --group_reporting

# ------------------------------------------------------------
# hdparm tests (sda attempt then correct nvme device)
# ------------------------------------------------------------

sudo hdparm -tT /dev/sda
sudo hdparm -tT /dev/nvme0n1

# ------------------------------------------------------------
# Monitor I/O performance during tests (multi-terminal)
# ------------------------------------------------------------

# Terminal 1: iostat continuous monitoring
iostat -x 2
# (Ctrl+C)

# Terminal 2: iotop (install if missing, then run)
sudo iotop -o
sudo apt install -y iotop
sudo iotop -o
# (Exit with q)

# Terminal 3: load + memory snapshot monitoring
watch -n 1 'cat /proc/loadavg; echo; cat /proc/meminfo | head -5'
# (Ctrl+C)

# ------------------------------------------------------------
# Analyze results and choose optimal scheduler
# ------------------------------------------------------------

# Create analysis script
nano analyze_results.sh

# Make executable
chmod +x analyze_results.sh

# Test mq-deadline scheduler + run analysis
echo mq-deadline | sudo tee /sys/block/nvme0n1/queue/scheduler
./analyze_results.sh

# Attempt bfq (not available)
echo bfq | sudo tee /sys/block/nvme0n1/queue/scheduler

# Attempt kyber (not available)
echo kyber | sudo tee /sys/block/nvme0n1/queue/scheduler

# ------------------------------------------------------------
# Document report + implement final choice
# ------------------------------------------------------------

# Write performance report file
nano performance_report.txt

# Create systemd service for persistent scheduler selection
sudo nano /etc/systemd/system/ioscheduler.service

# Enable + start service
sudo systemctl enable ioscheduler.service
sudo systemctl start ioscheduler.service

# Verify active scheduler
cat /sys/block/nvme0n1/queue/scheduler
