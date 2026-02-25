#!/bin/bash
echo "Analyzing resource usage for different file systems..."

monitor_resources() {
 local mount_point=$1
 local fs_type=$2

 echo "Testing resource usage for $fs_type"

 top -b -n 1 | head -5 > /tmp/cpu_before_${fs_type}.log
 free -h > /tmp/memory_before_${fs_type}.log

 cd $mount_point
 echo "Running intensive file operations..."

 time for i in {1..50}; do
  dd if=/dev/urandom of=resource_test_$i.dat bs=1M count=10 2>/dev/null
  gzip resource_test_$i.dat
  gunzip resource_test_$i.dat.gz
 done

 top -b -n 1 | head -5 > /tmp/cpu_after_${fs_type}.log
 free -h > /tmp/memory_after_${fs_type}.log

 rm -f resource_test_*.dat*

 echo "Resource monitoring completed for $fs_type"
}

monitor_resources "/mnt/ext4-tuned" "EXT4"
monitor_resources "/mnt/xfs-tuned" "XFS"
monitor_resources "/mnt/btrfs-tuned" "BTRFS"

echo "Resource usage analysis completed"
