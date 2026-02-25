#!/bin/bash
echo "=== Optimized Performance Test ==="
cd /mnt/optimized-fs

# Clean previous test files
rm -f file_*.txt

# Create test files
echo "Creating test files with optimized mount..."
time for i in {1..1000}; do
 echo "Test data $i" > file_$i.txt
done

# Read test files multiple times
echo "Reading test files with optimized mount..."
time for j in {1..5}; do
 for i in {1..1000}; do
  cat file_$i.txt > /dev/null
 done
done

# Check access times (should not update repeatedly)
echo "Sample file timestamps after reads:"
stat file_1.txt | grep -E "(Access|Modify|Change)"
