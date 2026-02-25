#!/bin/bash
# Memory Tuning Script

echo "Current Memory Configuration:"
echo "Swappiness: $(cat /proc/sys/vm/swappiness)"
echo "VFS Cache Pressure: $(cat /proc/sys/vm/vfs_cache_pressure)"

# Set optimal values for general workloads
sudo sysctl vm.swappiness=10
sudo sysctl vm.vfs_cache_pressure=50
sudo sysctl vm.dirty_ratio=15
sudo sysctl vm.dirty_background_ratio=5

echo "New Configuration Applied:"
echo "Swappiness: $(cat /proc/sys/vm/swappiness)"
echo "VFS Cache Pressure: $(cat /proc/sys/vm/vfs_cache_pressure)"
echo "Dirty Ratio: $(cat /proc/sys/vm/dirty_ratio)"
echo "Dirty Background Ratio: $(cat /proc/sys/vm/dirty_background_ratio)"
