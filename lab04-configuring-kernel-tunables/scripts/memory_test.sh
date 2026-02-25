#!/bin/bash
echo "Starting memory allocation test..."
# Allocate memory in chunks
for i in {1..5}; do
 echo "Allocating 100MB chunk $i..."
 # Create a 100MB file in memory
 dd if=/dev/zero of=/tmp/memtest_$i bs=1M count=100 2>/dev/null &
done
echo "Waiting for allocations to complete..."
wait
echo "Memory allocated. Checking system state..."
free -h
echo "Cleaning up..."
rm -f /tmp/memtest_*
echo "Memory test completed."
