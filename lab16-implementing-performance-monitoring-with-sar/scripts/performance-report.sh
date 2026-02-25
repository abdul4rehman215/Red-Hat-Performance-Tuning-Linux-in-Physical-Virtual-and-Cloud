# scripts/performance-report.sh
#!/bin/bash
# Comprehensive Performance Report Generator

# Set variables
REPORT_DATE=$(date +%Y-%m-%d)
REPORT_FILE="/tmp/performance-report-$REPORT_DATE.txt"
SA_FILE="/var/log/sa/sa$(date +%d)"

# Function to add section headers
add_header() {
 echo "========================================" >> $REPORT_FILE
 echo "$1" >> $REPORT_FILE
 echo "========================================" >> $REPORT_FILE
 echo >> $REPORT_FILE
}

# Initialize report
echo "SYSTEM PERFORMANCE REPORT" > $REPORT_FILE
echo "Generated: $(date)" >> $REPORT_FILE
echo "Hostname: $(hostname)" >> $REPORT_FILE
echo "Kernel: $(uname -r)" >> $REPORT_FILE
echo >> $REPORT_FILE

# CPU Performance Section
add_header "CPU PERFORMANCE ANALYSIS"
echo "CPU Utilization Summary:" >> $REPORT_FILE
sar -u | tail -1 >> $REPORT_FILE
echo >> $REPORT_FILE
echo "Load Average Trends:" >> $REPORT_FILE
sar -q | tail -5 >> $REPORT_FILE
echo >> $REPORT_FILE

# Memory Performance Section
add_header "MEMORY PERFORMANCE ANALYSIS"
echo "Memory Utilization Summary:" >> $REPORT_FILE
sar -r | tail -1 >> $REPORT_FILE
echo >> $REPORT_FILE
echo "Swap Usage Summary:" >> $REPORT_FILE
sar -S | tail -1 >> $REPORT_FILE
echo >> $REPORT_FILE

# Disk I/O Performance Section
add_header "DISK I/O PERFORMANCE ANALYSIS"
echo "Disk Utilization Summary:" >> $REPORT_FILE
sar -d | grep "Average" >> $REPORT_FILE
echo >> $REPORT_FILE

# Network Performance Section
add_header "NETWORK PERFORMANCE ANALYSIS"
echo "Network Interface Summary:" >> $REPORT_FILE
sar -n DEV | grep "Average" | grep -v lo >> $REPORT_FILE
echo >> $REPORT_FILE

# Performance Recommendations
add_header "PERFORMANCE RECOMMENDATIONS"

# CPU recommendations
CPU_UTIL=$(sar -u | tail -1 | awk '{print $3}')
if (( $(echo "$CPU_UTIL > 80" | bc -l) )); then
 echo "- HIGH CPU UTILIZATION DETECTED ($CPU_UTIL%)" >> $REPORT_FILE
 echo " Consider CPU optimization or scaling" >> $REPORT_FILE
fi

# Memory recommendations
MEM_UTIL=$(sar -r | tail -1 | awk '{print $4}')
if (( $(echo "$MEM_UTIL > 85" | bc -l) )); then
 echo "- HIGH MEMORY UTILIZATION DETECTED ($MEM_UTIL%)" >> $REPORT_FILE
 echo " Consider memory optimization or upgrade" >> $REPORT_FILE
fi

echo >> $REPORT_FILE
echo "Report generated successfully: $REPORT_FILE"
