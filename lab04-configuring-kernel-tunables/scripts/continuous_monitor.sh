#!/bin/bash
LOGFILE="/tmp/performance_log.txt"
INTERVAL=60 # Monitor every 60 seconds

echo "=== Continuous Performance Monitor Started ==="
echo "Logging to: $LOGFILE"
echo "Monitoring interval: ${INTERVAL} seconds"
echo "Press Ctrl+C to stop"
echo

# Function to log performance metrics
log_metrics() {
 local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

 {
   echo "[$timestamp] Performance Metrics"
   echo "Memory: $(free -m | awk '/^Mem:/ {printf \"Used: %dMB (%.1f%%), Available: %dMB\", $3, ($3/$2)*100, $7}')"
   echo "Swap: $(free -m | awk '/^Swap:/ {if($2>0) printf \"Used: %dMB (%.1f%%)\", $3, ($3/$2)*100; else print \"No swap configured\"}')"
   echo "Load: $(uptime | awk -F'load average:' '{print $2}' | sed 's/^ *//')"
   echo "TCP Connections: $(ss -t | wc -l) active"
   echo "---"
 } >> "$LOGFILE"
}

# Trap Ctrl+C to exit gracefully
trap 'echo "Monitoring stopped."; exit 0' INT

# Start monitoring loop
while true; do
 log_metrics
 echo "Logged metrics at $(date '+%H:%M:%S')"
 sleep $INTERVAL
done
