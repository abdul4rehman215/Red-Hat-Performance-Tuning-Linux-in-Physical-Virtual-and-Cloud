#!/bin/bash
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
PROFILE_NAME=$1
OUTPUT_DIR="$HOME/tuned_performance_data"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

LOGFILE="$OUTPUT_DIR/${PROFILE_NAME}_${TIMESTAMP}.log"

echo "=== Performance Monitoring for Profile: $PROFILE_NAME ===" > "$LOGFILE"
echo "Timestamp: $(date)" >> "$LOGFILE"
echo "" >> "$LOGFILE"

# System information
echo "=== System Information ===" >> "$LOGFILE"
uname -a >> "$LOGFILE"
echo "" >> "$LOGFILE"

# CPU information
echo "=== CPU Information ===" >> "$LOGFILE"
lscpu >> "$LOGFILE"
echo "" >> "$LOGFILE"

# Current tuned profile
echo "=== Current Tuned Profile ===" >> "$LOGFILE"
tuned-adm active >> "$LOGFILE"
echo "" >> "$LOGFILE"

# CPU governor
echo "=== CPU Governor ===" >> "$LOGFILE"
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor >> "$LOGFILE"
echo "" >> "$LOGFILE"

# I/O scheduler (NVMe on cloud VM)
echo "=== I/O Scheduler ===" >> "$LOGFILE"
if [ -f /sys/block/sda/queue/scheduler ]; then
  cat /sys/block/sda/queue/scheduler >> "$LOGFILE"
else
  cat /sys/block/nvme0n1/queue/scheduler >> "$LOGFILE"
fi
echo "" >> "$LOGFILE"

# Key kernel parameters
echo "=== Key Kernel Parameters ===" >> "$LOGFILE"
echo "vm.swappiness: $(sysctl -n vm.swappiness)" >> "$LOGFILE"
echo "kernel.sched_min_granularity_ns: $(sysctl -n kernel.sched_min_granularity_ns)" >> "$LOGFILE"
echo "net.core.rmem_max: $(sysctl -n net.core.rmem_max)" >> "$LOGFILE"
echo "" >> "$LOGFILE"

# Memory information
echo "=== Memory Information ===" >> "$LOGFILE"
free -h >> "$LOGFILE"
echo "" >> "$LOGFILE"

# Load average
echo "=== Load Average ===" >> "$LOGFILE"
uptime >> "$LOGFILE"
echo "" >> "$LOGFILE"

echo "Performance data collected in: $LOGFILE"
