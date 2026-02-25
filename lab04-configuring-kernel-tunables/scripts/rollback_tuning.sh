#!/bin/bash
echo "=== Kernel Parameter Rollback Script ==="
echo "This script will restore default kernel parameters"
echo

read -p "Are you sure you want to rollback all tuning changes? (y/N): " confirm
if [[ $confirm != [yY] ]]; then
 echo "Rollback cancelled."
 exit 0
fi

echo "Rolling back kernel parameters..."

# Restore default memory parameters
sudo sysctl vm.swappiness=60
sudo sysctl vm.dirty_ratio=20
sudo sysctl vm.dirty_background_ratio=10
sudo sysctl vm.dirty_writeback_centisecs=500
sudo sysctl vm.vfs_cache_pressure=100

# Restore default network parameters
sudo sysctl net.core.rmem_max=212992
sudo sysctl net.core.wmem_max=212992
sudo sysctl net.core.rmem_default=212992
sudo sysctl net.core.wmem_default=212992
sudo sysctl net.core.netdev_max_backlog=1000
sudo sysctl net.core.somaxconn=128

echo "Rollback completed."
echo "Note: To make rollback permanent, remove or rename:"
echo " /etc/sysctl.d/99-performance-tuning.conf"
