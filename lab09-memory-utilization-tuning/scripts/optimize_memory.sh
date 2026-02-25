#!/bin/bash
BACKUP_DIR="memory_config_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p $BACKUP_DIR

echo "Memory Optimization Script"
echo "========================="

# Backup current configuration
echo "Backing up current configuration..."
cp /etc/sysctl.conf $BACKUP_DIR/
sysctl -a | grep vm > $BACKUP_DIR/current_vm_settings.txt

# Detect system characteristics
TOTAL_RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
TOTAL_RAM_GB=$((TOTAL_RAM_KB / 1024 / 1024))

echo "System Analysis:"
echo " Total RAM: ${TOTAL_RAM_GB}GB"
echo " Current swappiness: $(cat /proc/sys/vm/swappiness)"

# Determine optimal settings based on RAM size and usage
if [ $TOTAL_RAM_GB -ge 8 ]; then
  OPTIMAL_SWAPPINESS=1
  OPTIMAL_VFS_CACHE=50
  OPTIMAL_DIRTY_RATIO=10
  OPTIMAL_DIRTY_BG_RATIO=3
  echo " Configuration: High-memory system"
elif [ $TOTAL_RAM_GB -ge 4 ]; then
  OPTIMAL_SWAPPINESS=10
  OPTIMAL_VFS_CACHE=100
  OPTIMAL_DIRTY_RATIO=15
  OPTIMAL_DIRTY_BG_RATIO=5
  echo " Configuration: Medium-memory system"
else
  OPTIMAL_SWAPPINESS=30
  OPTIMAL_VFS_CACHE=100
  OPTIMAL_DIRTY_RATIO=20
  OPTIMAL_DIRTY_BG_RATIO=10
  echo " Configuration: Low-memory system"
fi

# Apply optimizations
echo ""
echo "Applying optimizations..."

cat << SYSCTL_EOF >> /etc/sysctl.conf
# Memory optimization settings - Applied $(date)
# Swappiness: Lower values reduce swapping
vm.swappiness=$OPTIMAL_SWAPPINESS
# VFS cache pressure: Controls tendency to reclaim cache
vm.vfs_cache_pressure=$OPTIMAL_VFS_CACHE
# Dirty ratio: Percentage of memory that can be dirty before sync
vm.dirty_ratio=$OPTIMAL_DIRTY_RATIO
vm.dirty_background_ratio=$OPTIMAL_DIRTY_BG_RATIO
# Additional optimizations
vm.dirty_expire_centisecs=3000
vm.dirty_writeback_centisecs=500
SYSCTL_EOF

# Apply settings immediately
sudo sysctl -p

echo ""
echo "Optimization complete!"
echo "New settings:"
echo " Swappiness: $(cat /proc/sys/vm/swappiness)"
echo " VFS Cache Pressure: $(cat /proc/sys/vm/vfs_cache_pressure)"
echo " Dirty Ratio: $(cat /proc/sys/vm/dirty_ratio)"
echo " Dirty Background Ratio: $(cat /proc/sys/vm/dirty_background_ratio)"
echo ""
echo "Backup saved to: $BACKUP_DIR"
echo "To revert changes, restore from backup and run 'sudo sysctl -p'"
