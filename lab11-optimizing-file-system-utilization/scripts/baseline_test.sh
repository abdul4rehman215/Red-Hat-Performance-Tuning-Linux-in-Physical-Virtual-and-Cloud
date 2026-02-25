#!/bin/bash
echo "=== Baseline Performance Test ==="
cd /mnt/optimized-fs

# Create test files
echo "Creating test files..."
time for i in {1..1000}; do
 echo "Test data $i" > file_$i.txt
done

# Read test files multiple times
echo "Reading test files..."
time for j in {1..5}; do
 for i in {1..1000}; do
  cat file_$i.txt > /dev/null
 done
done

# Check access times
echo "Sample file timestamps:"
stat file_1.txt | grep -E "(Access|Modify|Change)"
