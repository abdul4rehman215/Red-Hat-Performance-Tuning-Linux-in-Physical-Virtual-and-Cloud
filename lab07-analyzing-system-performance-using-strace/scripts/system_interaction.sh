#!/bin/bash
echo "Starting system interaction demo..."

# File operations
echo "Performing file operations..."
ls -la /etc > file_list.txt
grep "passwd" file_list.txt > passwd_info.txt

# Network operations
echo "Testing network connectivity..."
ping -c 2 8.8.8.8 > /dev/null

# Process operations
echo "Checking processes..."
ps aux | head -5 > process_info.txt

# Memory information
echo "Checking memory..."
free -h > memory_info.txt

echo "Demo completed"

# Cleanup
rm -f file_list.txt passwd_info.txt process_info.txt memory_info.txt
