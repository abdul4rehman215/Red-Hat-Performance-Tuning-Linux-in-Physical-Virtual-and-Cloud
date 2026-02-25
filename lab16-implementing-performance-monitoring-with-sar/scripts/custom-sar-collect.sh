# scripts/custom-sar-collect.sh
#!/bin/bash
# Custom sar data collection script

# Set variables
LOG_DIR="/var/log/sar-custom"
DATE=$(date +%Y%m%d)
TIME=$(date +%H%M%S)

# Create log directory if it doesn't exist
mkdir -p $LOG_DIR

# Collect comprehensive system data
echo "Starting comprehensive system monitoring at $(date)" >> $LOG_DIR/sar-$DATE.log

# CPU utilization every 2 seconds for 30 samples
sar -u 2 30 >> $LOG_DIR/cpu-$DATE-$TIME.log &

# Memory utilization
sar -r 2 30 >> $LOG_DIR/memory-$DATE-$TIME.log &

# Disk I/O statistics
sar -d 2 30 >> $LOG_DIR/disk-$DATE-$TIME.log &

# Network statistics
sar -n DEV 2 30 >> $LOG_DIR/network-$DATE-$TIME.log &

# Wait for background sar jobs to finish
wait

echo "Data collection completed at $(date)" >> $LOG_DIR/sar-$DATE.log
