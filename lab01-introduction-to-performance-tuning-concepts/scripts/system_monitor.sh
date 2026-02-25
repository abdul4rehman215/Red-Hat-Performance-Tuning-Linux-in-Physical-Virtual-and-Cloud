#!/bin/bash
LOGFILE="system_performance.log"
DURATION=60 # Monitor for 60 seconds

echo "=== System Performance Monitoring ===" | tee $LOGFILE
echo "Monitoring started at: $(date)" | tee -a $LOGFILE
echo "Duration: $DURATION seconds" | tee -a $LOGFILE
echo "" | tee -a $LOGFILE

# Function to log system metrics
log_metrics() {
 echo "=== Timestamp: $(date) ===" >> $LOGFILE

 # CPU utilization
 echo "CPU Usage:" >> $LOGFILE
 top -bn1 | grep "Cpu(s)" >> $LOGFILE

 # Memory utilization
 echo "Memory Usage:" >> $LOGFILE
 free -h >> $LOGFILE

 # Disk I/O
 echo "Disk I/O:" >> $LOGFILE
 iostat -x 1 1 >> $LOGFILE 2>/dev/null || echo "iostat not available" >> $LOGFILE

 # Network usage
 echo "Network Interfaces:" >> $LOGFILE
 cat /proc/net/dev | head -3 >> $LOGFILE

 # Load average
 echo "Load Average:" >> $LOGFILE
 uptime >> $LOGFILE

 echo "----------------------------------------" >> $LOGFILE
}

# Monitor system for specified duration
echo "Starting system monitoring..."
for i in $(seq 1 6); do
 log_metrics
 echo "Sample $i/6 collected..."
 sleep 10
done

echo "Monitoring complete. Results saved to $LOGFILE"
echo "Use 'cat $LOGFILE' to view detailed results"
