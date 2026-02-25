#!/bin/bash
LOG_FILE="memory_usage.log"
INTERVAL=5
COUNT=12

echo "Starting memory monitoring for $(($INTERVAL * $COUNT)) seconds..."
echo "Logging to: $LOG_FILE"

# Create log header
echo "=== Memory Monitoring Started: $(date) ===" > $LOG_FILE
echo "Timestamp,Total(MB),Used(MB),Free(MB),Available(MB),Buff/Cache(MB)" >> $LOG_FILE

# Monitor memory usage
for i in $(seq 1 $COUNT); do
  TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
  MEMORY_INFO=$(free -m | awk 'NR==2{printf "%s,%s,%s,%s,%s", $2,$3,$4,$7,$6}')
  echo "$TIMESTAMP,$MEMORY_INFO" >> $LOG_FILE
  echo "Sample $i: $(free -h | awk 'NR==2{print $3 " used of " $2 " total"}')"
  sleep $INTERVAL
done

echo "Monitoring complete. Check $LOG_FILE for detailed results."
