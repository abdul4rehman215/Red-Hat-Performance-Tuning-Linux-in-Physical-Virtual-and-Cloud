#!/bin/bash
echo "=== System Performance Analysis ==="
echo "Analysis performed at: $(date)"
echo

echo "=== CPU Information ==="
lscpu | grep -E "(Model name|CPU\(s\)|Thread|Core)"
echo

echo "=== Memory Analysis ==="
echo "Total Memory:"
free -h | grep -E "(Mem|Swap)"
echo

echo "Memory Pressure (if available):"
if [ -f /proc/pressure/memory ]; then
 cat /proc/pressure/memory
else
 echo "Memory pressure information not available"
fi
echo

echo "=== I/O Performance ==="
echo "Dirty Pages Status:"
grep -E "(Dirty|Writeback)" /proc/meminfo
echo

echo "=== Network Performance Indicators ==="
echo "Network Interface Statistics:"
cat /proc/net/dev | head -3
echo

echo "TCP Connection States:"
ss -s
echo

echo "=== Current Kernel Parameters ==="
echo "Key VM Parameters:"
sysctl vm.swappiness vm.dirty_ratio vm.vfs_cache_pressure
echo

echo "Key Network Parameters:"
sysctl net.core.rmem_max net.core.wmem_max net.core.somaxconn
echo

echo "=== System Load ==="
uptime
echo
