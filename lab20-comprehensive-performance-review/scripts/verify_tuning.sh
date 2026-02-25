#!/bin/bash
echo "TUNING VERIFICATION"
echo "==================="

echo "Memory Settings:"
echo "---------------"
echo "Swappiness: $(cat /proc/sys/vm/swappiness)"
echo "Dirty Ratio: $(cat /proc/sys/vm/dirty_ratio)"
echo "Dirty Background Ratio: $(cat /proc/sys/vm/dirty_background_ratio)"
echo ""

echo "I/O Schedulers:"
echo "--------------"
for disk in $(lsblk -d -n -o NAME | grep -E '^[a-z]+$'); do
 scheduler=$(cat /sys/block/$disk/queue/scheduler | grep -o '\[.*\]' | tr -d '[]')
 rotational=$(cat /sys/block/$disk/queue/rotational)
 disk_type=$([ "$rotational" = "0" ] && echo "SSD" || echo "HDD")
 echo "$disk ($disk_type): $scheduler"
done
echo ""

echo "Network Settings:"
echo "----------------"
echo "Receive buffer max: $(cat /proc/sys/net/core/rmem_max)"
echo "Send buffer max: $(cat /proc/sys/net/core/wmem_max)"
echo "TCP window scaling: $(cat /proc/sys/net/ipv4/tcp_window_scaling)"
echo ""

echo "Persistent Configuration:"
echo "------------------------"
if [ -f /etc/sysctl.d/99-performance-tuning.conf ]; then
 echo "✓ Persistent configuration file exists"
 echo "Contents:"
 cat /etc/sysctl.d/99-performance-tuning.conf
else
 echo " Persistent configuration file not found"
fi
