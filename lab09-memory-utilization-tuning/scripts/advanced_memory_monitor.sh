#!/bin/bash
DURATION=60
INTERVAL=5
LOG_FILE="advanced_memory_$(date +%Y%m%d_%H%M%S).log"

echo "Advanced Memory Monitoring"
echo "Duration: $DURATION seconds"
echo "Interval: $INTERVAL seconds"
echo "Log file: $LOG_FILE"

# Create log file with headers
{
  echo "=== Advanced Memory Monitoring Started: $(date) ==="
  echo ""
  echo "Initial System State:"
  echo "===================="
  free -h
  echo ""
  echo "Swap Information:"
  swapon --show
  echo ""
  echo "Memory Parameters:"
  echo "Swappiness: $(cat /proc/sys/vm/swappiness)"
  echo "VFS Cache Pressure: $(cat /proc/sys/vm/vfs_cache_pressure)"
  echo ""
  echo "=== Continuous Monitoring ==="
  echo ""
} > $LOG_FILE

# Start monitoring
echo "Monitoring started... Press Ctrl+C to stop early"

vmstat $INTERVAL $(($DURATION / $INTERVAL)) >> $LOG_FILE &
VMSTAT_PID=$!

# Also log free output periodically
{
  for i in $(seq 1 $(($DURATION / $INTERVAL))); do
    echo "--- Sample $i at $(date) ---" >> ${LOG_FILE}.free
    free -h >> ${LOG_FILE}.free
    echo "" >> ${LOG_FILE}.free
    sleep $INTERVAL
  done
} &
FREE_PID=$!

# Wait for monitoring to complete
wait $VMSTAT_PID
wait $FREE_PID

echo "Monitoring complete!"
echo "Results saved to:"
echo " - $LOG_FILE (vmstat output)"
echo " - ${LOG_FILE}.free (free command output)"
