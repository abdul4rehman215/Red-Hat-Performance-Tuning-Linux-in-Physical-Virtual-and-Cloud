#!/bin/bash
echo "Starting I/O monitoring for file system comparison..."

# Function to monitor I/O for a specific device
monitor_io() {
 local device=$1
 local fs_type=$2
 local mount_point=$3

 echo "Monitoring $fs_type ($device) at $mount_point"

 # Start iostat monitoring in background
 iostat -x 1 10 $device > /tmp/iostat_${fs_type}.log &
 local iostat_pid=$!

 # Run a mixed workload
 cd $mount_point

 for i in {1..100}; do
  dd if=/dev/urandom of=workload_file_$i.dat bs=1k count=100 2>/dev/null
  cat workload_file_$i.dat > /dev/null
  echo "Modified at $(date)" >> workload_file_$i.dat
  sleep 0.1
 done

 # Stop iostat monitoring
 kill $iostat_pid 2>/dev/null
 wait $iostat_pid 2>/dev/null

 # Clean up
 rm -f workload_file_*.dat

 echo "I/O monitoring completed for $fs_type"
}

monitor_io "loop1" "EXT4" "/mnt/ext4-tuned"
monitor_io "loop2" "XFS" "/mnt/xfs-tuned"
monitor_io "loop3" "BTRFS" "/mnt/btrfs-tuned"

echo "I/O monitoring completed for all file systems"
echo "Results saved in /tmp/iostat_*.log files"
