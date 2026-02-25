#!/bin/bash
echo "=== Memory Performance Monitor ==="
echo "Timestamp: $(date)"
echo
echo "=== Memory Usage ==="
free -h
echo
echo "=== Swap Information ==="
swapon --show
echo
echo "=== Key VM Parameters ==="
echo "vm.swappiness = $(sysctl -n vm.swappiness)"
echo "vm.dirty_ratio = $(sysctl -n vm.dirty_ratio)"
echo "vm.dirty_background_ratio = $(sysctl -n vm.dirty_background_ratio)"
echo "vm.vfs_cache_pressure = $(sysctl -n vm.vfs_cache_pressure)"
echo
echo "=== Memory Pressure ==="
cat /proc/pressure/memory 2>/dev/null || echo "Memory pressure info not available"
echo
