# scripts/monitor_performance.sh
#!/bin/bash
MONITOR_FILE="system_monitoring.txt"
DURATION=60

echo "=== SYSTEM PERFORMANCE MONITORING ===" > $MONITOR_FILE
echo "Monitor Duration: ${DURATION} seconds" >> $MONITOR_FILE
echo "Start Time: $(date)" >> $MONITOR_FILE
echo "" >> $MONITOR_FILE

# Start background monitoring
(
  echo "=== CPU Usage ===" >> $MONITOR_FILE
  sar -u 5 $((DURATION/5)) >> $MONITOR_FILE
  echo "" >> $MONITOR_FILE

  echo "=== Memory Usage ===" >> $MONITOR_FILE
  sar -r 5 $((DURATION/5)) >> $MONITOR_FILE
  echo "" >> $MONITOR_FILE

  echo "=== Network Interface Statistics ===" >> $MONITOR_FILE
  sar -n DEV 5 $((DURATION/5)) >> $MONITOR_FILE
  echo "" >> $MONITOR_FILE

  echo "=== Network Error Statistics ===" >> $MONITOR_FILE
  sar -n EDEV 5 $((DURATION/5)) >> $MONITOR_FILE
  echo "" >> $MONITOR_FILE
) &

MONITOR_PID=$!

# Run network test while monitoring
echo "Starting network test with monitoring..."
SERVER_IP="172.31.20.10" # Replace with your server IP
iperf3 -c $SERVER_IP -p 5001 -t $DURATION -P 4

# Wait for monitoring to complete
wait $MONITOR_PID
echo "Monitoring completed. Results saved to $MONITOR_FILE"
