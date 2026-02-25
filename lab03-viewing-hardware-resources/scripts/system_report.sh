#!/bin/bash
echo "=== SYSTEM RESOURCE ANALYSIS REPORT ==="
echo "Generated on: $(date)"
echo ""

echo "=== CPU INFORMATION ==="
lscpu | grep -E "(Model name|CPU\(s\)|Thread|Core|Socket|MHz)"
echo ""

echo "=== MEMORY UTILIZATION ==="
free -h
echo ""

echo "=== STORAGE DEVICES ==="
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE
echo ""

echo "=== DISK USAGE ==="
df -h
echo ""

echo "=== SYSTEM LOAD ==="
uptime
echo ""

echo "=== NETWORK INTERFACES ==="
ip link show | grep -E "(^[0-9]|state)"
