#!/bin/bash

# Function to run benchmark on a specific mount point
run_benchmark() {
 local mount_point=$1
 local fs_type=$2

 echo "========================================="
 echo "Benchmarking $fs_type at $mount_point"
 echo "========================================="

 cd $mount_point

 # Clean any existing test files
 rm -rf benchmark_test_*

 # Test 1: Sequential write performance
 echo "Test 1: Sequential Write (100MB file)"
 sync && echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
 time dd if=/dev/zero of=benchmark_test_seq_write.dat bs=1M count=100 oflag=direct 2>/dev/null

 # Test 2: Sequential read performance
 echo "Test 2: Sequential Read (100MB file)"
 sync && echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
 time dd if=benchmark_test_seq_write.dat of=/dev/null bs=1M iflag=direct 2>/dev/null

 # Test 3: Random small file creation
 echo "Test 3: Small File Creation (1000 files)"
 sync && echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
 time for i in {1..1000}; do
  echo "Test data $i $(date)" > benchmark_test_small_$i.txt
 done

 # Test 4: Random small file reading
 echo "Test 4: Small File Reading (1000 files)"
 sync && echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
 time for i in {1..1000}; do
  cat benchmark_test_small_$i.txt > /dev/null
 done

 # Test 5: Directory operations
 echo "Test 5: Directory Operations"
 sync && echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
 time for i in {1..100}; do
  mkdir -p benchmark_test_dir_$i
  touch benchmark_test_dir_$i/file_{1..10}.txt
 done

 # Test 6: File deletion
 echo "Test 6: File Deletion"
 sync && echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
 time rm -rf benchmark_test_*

 echo "Benchmark completed for $fs_type"
 echo ""
}

# Run benchmarks on all file systems
run_benchmark "/mnt/ext4-tuned" "EXT4"
run_benchmark "/mnt/xfs-tuned" "XFS"
run_benchmark "/mnt/btrfs-tuned" "BTRFS"

echo "All benchmarks completed!"
