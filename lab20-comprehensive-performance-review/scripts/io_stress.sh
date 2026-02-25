#!/bin/bash
echo "Starting I/O stress test..."
# Create test directory
mkdir -p /tmp/io_test
cd /tmp/io_test
# Write test - create multiple files
for i in {1..5}; do
 dd if=/dev/zero of=testfile_${i}.dat bs=1M count=100 2>/dev/null &
done
sleep 60 # Let write operations run
# Read test - read the files
for i in {1..5}; do
 dd if=testfile_${i}.dat of=/dev/null bs=1M 2>/dev/null &
done
sleep 60 # Let read operations run
# Cleanup
rm -f testfile_*.dat
cd /opt/performance-review
echo "I/O stress test completed."
