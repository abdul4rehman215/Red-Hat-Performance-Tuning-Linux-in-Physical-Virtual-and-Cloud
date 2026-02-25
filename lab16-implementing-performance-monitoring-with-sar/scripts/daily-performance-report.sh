# scripts/daily-performance-report.sh
#!/bin/bash
# Automated Daily Performance Report

# Configuration
REPORT_DIR="/var/log/performance-reports"
REPORT_DATE=$(date +%Y-%m-%d)
REPORT_FILE="$REPORT_DIR/daily-report-$REPORT_DATE.txt"
EMAIL_RECIPIENT="admin@company.com" # Change as needed

# Create report directory
mkdir -p $REPORT_DIR

# Generate report header
cat > $REPORT_FILE << EOF
DAILY PERFORMANCE REPORT
========================
Date: $REPORT_DATE
Hostname: $(hostname)
Uptime: $(uptime)
EOF

# System overview
echo "SYSTEM OVERVIEW:" >> $REPORT_FILE
echo "===============" >> $REPORT_FILE
echo "CPU Cores: $(nproc)" >> $REPORT_FILE
echo "Total Memory: $(free -h | awk '/^Mem:/ {print $2}')" >> $REPORT_FILE
echo "Disk Usage: $(df -h / | awk 'NR==2 {print $5}')" >> $REPORT_FILE
echo >> $REPORT_FILE

# Performance metrics
echo "PERFORMANCE METRICS:" >> $REPORT_FILE
echo "===================" >> $REPORT_FILE

# CPU metrics
echo "CPU Utilization:" >> $REPORT_FILE
sar -u | tail -1 >> $REPORT_FILE
echo >> $REPORT_FILE

# Memory metrics
echo "Memory Utilization:" >> $REPORT_FILE
sar -r | tail -1 >> $REPORT_FILE
echo >> $REPORT_FILE

# Disk I/O metrics
echo "Disk I/O Summary:" >> $REPORT_FILE
sar -d | grep "Average" | head -5 >> $REPORT_FILE
echo >> $REPORT_FILE

# Network metrics
echo "Network Activity:" >> $REPORT_FILE
sar -n DEV | grep "Average" | grep -v lo >> $REPORT_FILE
echo >> $REPORT_FILE

# Performance alerts
echo "PERFORMANCE ALERTS:" >> $REPORT_FILE
echo "==================" >> $REPORT_FILE

# Check for high CPU usage
HIGH_CPU=$(sar -u | tail -1 | awk '$3 > 80 {print "HIGH CPU USAGE: " $3"%"}')
if [ ! -z "$HIGH_CPU" ]; then
 echo " $HIGH_CPU" >> $REPORT_FILE
fi

# Check for high memory usage
HIGH_MEM=$(sar -r | tail -1 | awk '$4 > 85 {print "HIGH MEMORY USAGE: " $4"%"}')
if [ ! -z "$HIGH_MEM" ]; then
 echo " $HIGH_MEM" >> $REPORT_FILE
fi

# Check for high disk utilization
HIGH_DISK=$(sar -d | awk '$NF > 80 {print "HIGH DISK UTILIZATION: " $2 " " $NF"%"}')
if [ ! -z "$HIGH_DISK" ]; then
 echo " $HIGH_DISK" >> $REPORT_FILE
fi

echo >> $REPORT_FILE
echo "Report generated at: $(date)" >> $REPORT_FILE

# Optional: Send email report (requires mail command)
# mail -s "Daily Performance Report - $(hostname)" $EMAIL_RECIPIENT < $REPORT_FILE

echo "Daily report generated: $REPORT_FILE"
