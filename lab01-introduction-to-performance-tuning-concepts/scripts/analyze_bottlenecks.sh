#!/bin/bash
echo "=== Bottleneck Analysis Tool ==="
echo ""

# Check CPU utilization
echo "1. CPU Analysis:"
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
echo " Current CPU usage: ${cpu_usage}%"
if (( $(echo "$cpu_usage > 80" | bc -l) )); then
 echo " HIGH CPU USAGE DETECTED - Potential CPU bottleneck"
else
 echo " CPU usage is normal"
fi
echo ""

# Check Memory utilization
echo "2. Memory Analysis:"
memory_info=$(free | grep Mem)
total_mem=$(echo $memory_info | awk '{print $2}')
used_mem=$(echo $memory_info | awk '{print $3}')
memory_percent=$(echo "scale=2; $used_mem * 100 / $total_mem" | bc)
echo " Memory usage: ${memory_percent}%"
if (( $(echo "$memory_percent > 85" | bc -l) )); then
 echo " HIGH MEMORY USAGE DETECTED - Potential memory bottleneck"
else
 echo " Memory usage is normal"
fi
echo ""

# Check Load Average
echo "3. Load Average Analysis:"
load_avg=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | tr -d ',')
cpu_cores=$(nproc)
load_per_core=$(echo "scale=2; $load_avg / $cpu_cores" | bc)
echo " Load average: $load_avg (${cpu_cores} cores available)"
echo " Load per core: $load_per_core"
if (( $(echo "$load_per_core > 1.0" | bc -l) )); then
 echo " HIGH LOAD AVERAGE - System may be overloaded"
else
 echo " Load average is acceptable"
fi
echo ""

# Check Disk Usage
echo "4. Disk Usage Analysis:"
disk_usage=$(df / | tail -1 | awk '{print $5}' | tr -d '%')
echo " Root filesystem usage: ${disk_usage}%"
if [ $disk_usage -gt 90 ]; then
 echo " HIGH DISK USAGE - Potential storage bottleneck"
else
 echo " Disk usage is normal"
fi
echo ""

echo "=== Bottleneck Analysis Complete ==="
