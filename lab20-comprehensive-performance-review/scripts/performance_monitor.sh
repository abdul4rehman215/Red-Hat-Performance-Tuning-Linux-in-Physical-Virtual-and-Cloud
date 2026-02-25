#!/bin/bash
# Comprehensive Performance Monitoring Script
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
MONITOR_DIR="/opt/performance-review/monitoring"
DURATION=300 # 5 minutes monitoring

echo "Starting comprehensive performance monitoring..."
echo "Duration: ${DURATION} seconds"
echo "Timestamp: ${TIMESTAMP}"

# Create timestamped directory
mkdir -p "${MONITOR_DIR}/${TIMESTAMP}"
cd "${MONITOR_DIR}/${TIMESTAMP}"

# Function to run monitoring tools in background
start_monitoring() {
 echo "Initializing monitoring tools..."

 # CPU and process monitoring with top
 top -b -d 2 -n $((DURATION/2)) > top_output.txt &
 TOP_PID=$!

 # I/O statistics monitoring
 iostat -x 2 $((DURATION/2)) > iostat_output.txt &
 IOSTAT_PID=$!

 # System activity reporting
 sar -u -r -d -n DEV 2 $((DURATION/2)) > sar_output.txt &
 SAR_PID=$!

 # Additional system metrics
 vmstat 2 $((DURATION/2)) > vmstat_output.txt &
 VMSTAT_PID=$!

 # Memory usage tracking
 while [ $DURATION -gt 0 ]; do
 echo "$(date): $(free -m | grep Mem)" >> memory_tracking.txt
 sleep 5
 DURATION=$((DURATION-5))
 done &
 MEMORY_PID=$!

 # Store process IDs for cleanup
 echo "$TOP_PID $IOSTAT_PID $SAR_PID $VMSTAT_PID $MEMORY_PID" > monitor_pids.txt

 echo "All monitoring tools started. PIDs saved to monitor_pids.txt"
 echo "Monitoring will run for 5 minutes..."
}

# Function to stop monitoring
stop_monitoring() {
 echo "Stopping monitoring tools..."
 if [ -f monitor_pids.txt ]; then
 for pid in $(cat monitor_pids.txt); do
 kill $pid 2>/dev/null || true
 done
 rm -f monitor_pids.txt
 fi
 echo "Monitoring stopped."
}

# Trap to ensure cleanup on script exit
trap stop_monitoring EXIT

# Start monitoring
start_monitoring

# Wait for monitoring to complete
sleep 305
echo "Performance monitoring completed. Data saved in: ${MONITOR_DIR}/${TIMESTAMP}"
