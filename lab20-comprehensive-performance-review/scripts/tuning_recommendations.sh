#!/bin/bash
echo "SYSTEM TUNING RECOMMENDATIONS"
echo "=============================="

# Create backup of current settings
BACKUP_DIR="/opt/performance-review/backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
echo "Creating backup of current settings in: $BACKUP_DIR"

# Backup current tunables
echo "$(cat /proc/sys/vm/swappiness)" > "$BACKUP_DIR/swappiness.bak"
echo "$(cat /proc/sys/vm/dirty_ratio)" > "$BACKUP_DIR/dirty_ratio.bak"
echo "$(cat /proc/sys/vm/dirty_background_ratio)" > "$BACKUP_DIR/dirty_background_ratio.bak"

# Network settings backup
echo "$(cat /proc/sys/net/core/rmem_max)" > "$BACKUP_DIR/rmem_max.bak"
echo "$(cat /proc/sys/net/core/wmem_max)" > "$BACKUP_DIR/wmem_max.bak"

echo "Backup completed."
echo ""
echo "RECOMMENDED TUNING PARAMETERS:"
echo "------------------------------"

# Memory tuning recommendations
current_swappiness=$(cat /proc/sys/vm/swappiness)
echo "Current swappiness: $current_swappiness"
if [ "$current_swappiness" -gt 10 ]; then
 echo "✓ Recommendation: Reduce swappiness to 10 for better performance"
 echo " Command: echo 10 | sudo tee /proc/sys/vm/swappiness"
fi

# Dirty ratio tuning
current_dirty=$(cat /proc/sys/vm/dirty_ratio)
echo "Current dirty_ratio: $current_dirty"
if [ "$current_dirty" -gt 15 ]; then
 echo "✓ Recommendation: Reduce dirty_ratio to 15 for better I/O performance"
 echo " Command: echo 15 | sudo tee /proc/sys/vm/dirty_ratio"
fi

# I/O scheduler recommendations
echo ""
echo "I/O SCHEDULER RECOMMENDATIONS:"
for disk in $(lsblk -d -n -o NAME | grep -E '^[a-z]+$'); do
 current_scheduler=$(cat /sys/block/$disk/queue/scheduler | grep -o '\[.*\]' | tr -d '[]')
 echo "Disk $disk current scheduler: $current_scheduler"

 # Check if it's SSD or HDD
 rotational=$(cat /sys/block/$disk/queue/rotational)
 if [ "$rotational" = "0" ]; then
  echo "✓ SSD detected - Recommend 'noop' or 'deadline' scheduler"
  echo " Command: echo noop | sudo tee /sys/block/$disk/queue/scheduler"
 else
  echo "✓ HDD detected - Recommend 'cfq' scheduler"
  echo " Command: echo cfq | sudo tee /sys/block/$disk/queue/scheduler"
 fi
done

echo ""
echo "NETWORK TUNING RECOMMENDATIONS:"
echo "-------------------------------"
current_rmem=$(cat /proc/sys/net/core/rmem_max)
current_wmem=$(cat /proc/sys/net/core/wmem_max)
if [ "$current_rmem" -lt 16777216 ]; then
 echo "✓ Increase network receive buffer size"
 echo " Command: echo 16777216 | sudo tee /proc/sys/net/core/rmem_max"
fi
if [ "$current_wmem" -lt 16777216 ]; then
 echo "✓ Increase network send buffer size"
 echo " Command: echo 16777216 | sudo tee /proc/sys/net/core/wmem_max"
fi

echo ""
echo "To apply all recommendations, run: ./scripts/apply_tuning.sh"
