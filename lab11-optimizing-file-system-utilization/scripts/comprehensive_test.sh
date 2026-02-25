#!/bin/bash
echo "=== Comprehensive Performance Test ==="
cd /mnt/optimized-fs

# Clean previous test files
rm -f file_*.txt large_file.dat

# Test 1: Small file operations
echo "Test 1: Small file I/O performance"
time for i in {1..2000}; do
 echo "Test data for file $i with timestamp $(date)" > small_file_$i.txt
done

# Test 2: Large file operations
echo "Test 2: Large file I/O performance"
time dd if=/dev/zero of=large_file.dat bs=1M count=100 2>/dev/null

# Test 3: Directory operations
echo "Test 3: Directory operations"
time for i in {1..100}; do
 mkdir -p dir_$i
 touch dir_$i/file_{1..10}.txt
done

# Test 4: File deletion performance
echo "Test 4: File deletion performance"
time rm -rf dir_* small_file_*.txt large_file.dat

echo "Comprehensive test completed"
