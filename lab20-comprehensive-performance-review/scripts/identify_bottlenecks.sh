#!/bin/bash
echo "PERFORMANCE BOTTLENECK IDENTIFICATION"
echo "====================================="

# Check current system tunables
echo "Current System Configuration:"
echo "-----------------------------"

# CPU-related settings
echo "CPU Scaling Governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo 'Not available')"

# Memory settings
echo "Swappiness: $(cat /proc/sys/vm/swappiness)"
echo "Dirty Ratio: $(cat /proc/sys/vm/dirty_ratio)"
echo "Dirty Background Ratio: $(cat /proc/sys/vm/dirty_background_ratio)"

# I/O scheduler
for disk in $(lsblk -d -n -o NAME | grep -E '^[a-z]+$'); do
 scheduler=$(cat /sys/block/$disk/queue/scheduler 2>/dev/null || echo 'N/A')
 echo "I/O Scheduler for $disk: $scheduler"
done

# Network settings
echo "TCP Congestion Control: $(cat /proc/sys/net/ipv4/tcp_congestion_control)"
echo "TCP Window Scaling: $(cat /proc/sys/net/ipv4/tcp_window_scaling)"
echo ""
echo "BOTTLENECK ANALYSIS:"
echo "-------------------"

# Check CPU usage
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')
if command -v bc >/dev/null 2>&1; then
 if (( $(echo "$cpu_usage > 80" | bc -l) )); then
  echo " HIGH CPU USAGE DETECTED: ${cpu_usage}%"
  echo " Recommendation: Check CPU governor, consider process optimization"
 fi
else
 echo "Note: bc not installed, skipping numeric comparisons for CPU usage."
fi

# Check memory usage
mem_usage=$(free | grep Mem | awk '{printf "%.1f", ($3/$2) * 100.0}')
if command -v bc >/dev/null 2>&1; then
 if (( $(echo "$mem_usage > 85" | bc -l) )); then
  echo " HIGH MEMORY USAGE DETECTED: ${mem_usage}%"
  echo " Recommendation: Adjust swappiness, check for memory leaks"
 fi
fi

# Check swap usage
swap_usage=$(free | grep Swap | awk '{if($2>0) printf "%.1f", ($3/$2) * 100.0; else print "0"}')
if command -v bc >/dev/null 2>&1; then
 if (( $(echo "$swap_usage > 10" | bc -l) )); then
  echo " SWAP USAGE DETECTED: ${swap_usage}%"
  echo " Recommendation: Increase RAM or optimize memory usage"
 fi
fi

# Check disk I/O wait
io_wait=$(iostat -c 1 2 | tail -1 | awk '{print $4}')
if command -v bc >/dev/null 2>&1; then
 if (( $(echo "$io_wait > 20" | bc -l) )); then
  echo " HIGH I/O WAIT DETECTED: ${io_wait}%"
  echo " Recommendation: Check I/O scheduler, disk performance"
 fi
fi

# Check load average
load_avg=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
cpu_cores=$(nproc)
if command -v bc >/dev/null 2>&1; then
 if (( $(echo "$load_avg > $cpu_cores" | bc -l) )); then
  echo " HIGH LOAD AVERAGE: $load_avg (CPU cores: $cpu_cores)"
  echo " Recommendation: Investigate running processes"
 fi
fi

echo ""
echo "Bottleneck identification completed."
