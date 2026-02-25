#!/bin/bash
echo "APPLYING PERFORMANCE TUNING"
echo "==========================="

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then
 echo "This script requires root privileges. Please run with sudo."
 exit 1
fi

echo "Applying memory tuning..."
# Memory tuning
echo 10 > /proc/sys/vm/swappiness
echo "✓ Swappiness set to 10"
echo 15 > /proc/sys/vm/dirty_ratio
echo "✓ Dirty ratio set to 15"
echo 5 > /proc/sys/vm/dirty_background_ratio
echo "✓ Dirty background ratio set to 5"

# I/O scheduler tuning
echo "Applying I/O scheduler tuning..."
for disk in $(lsblk -d -n -o NAME | grep -E '^[a-z]+$'); do
 rotational=$(cat /sys/block/$disk/queue/rotational)
 if [ "$rotational" = "0" ]; then
  # SSD - use noop scheduler (fallback to mq-deadline if noop not supported)
  echo noop > /sys/block/$disk/queue/scheduler 2>/dev/null || echo mq-deadline > /sys/block/$disk/queue/scheduler
  echo "✓ Set scheduler for SSD $disk to noop/mq-deadline"
 else
  # HDD - use cfq scheduler (fallback to mq-deadline if cfq not supported)
  echo cfq > /sys/block/$disk/queue/scheduler 2>/dev/null || echo mq-deadline > /sys/block/$disk/queue/scheduler
  echo "✓ Set scheduler for HDD $disk to cfq/mq-deadline"
 fi
done

# Network tuning
echo "Applying network tuning..."
echo 16777216 > /proc/sys/net/core/rmem_max
echo 16777216 > /proc/sys/net/core/wmem_max
echo "✓ Network buffer sizes increased"

# TCP tuning
echo 1 > /proc/sys/net/ipv4/tcp_window_scaling
echo "✓ TCP window scaling enabled"

# Create persistent configuration
echo "Creating persistent configuration..."
cat > /etc/sysctl.d/99-performance-tuning.conf << 'SYSCTL_EOF'
# Performance tuning applied by lab
vm.swappiness = 10
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_window_scaling = 1
SYSCTL_EOF

echo "✓ Persistent configuration saved to /etc/sysctl.d/99-performance-tuning.conf"
echo ""
echo "TUNING APPLIED SUCCESSFULLY!"
echo "Changes will persist after reboot."
echo ""
echo "Current settings verification:"
echo "Swappiness: $(cat /proc/sys/vm/swappiness)"
echo "Dirty ratio: $(cat /proc/sys/vm/dirty_ratio)"
echo "Network rmem_max: $(cat /proc/sys/net/core/rmem_max)"
