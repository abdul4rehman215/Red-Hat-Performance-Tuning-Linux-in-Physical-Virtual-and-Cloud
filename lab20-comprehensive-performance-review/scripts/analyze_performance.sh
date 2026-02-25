#!/bin/bash
# Performance Data Analysis Script
LATEST_DIR=$(ls -1t /opt/performance-review/monitoring/ | head -1)
DATA_DIR="/opt/performance-review/monitoring/${LATEST_DIR}"
REPORT_DIR="/opt/performance-review/reports"
mkdir -p "$REPORT_DIR"
REPORT_FILE="${REPORT_DIR}/performance_analysis_$(date +%Y%m%d_%H%M%S).txt"
echo "Performance Analysis Report - $(date)" > "$REPORT_FILE"
echo "=========================================" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Analyze CPU usage from top output
echo "CPU USAGE ANALYSIS:" >> "$REPORT_FILE"
echo "-------------------" >> "$REPORT_FILE"
if [ -f "${DATA_DIR}/top_output.txt" ]; then
 # Extract CPU usage statistics
 grep "Cpu(s)" "${DATA_DIR}/top_output.txt" | head -10 | \
 awk '{print $2}' | sed 's/%us,//' | \
 awk '{sum+=$1; count++} END {if(count>0) printf "Average CPU Usage: %.2f%%\n", sum/count}' >> "$REPORT_FILE"

 # Find highest CPU consuming processes
 echo "Top CPU consuming processes:" >> "$REPORT_FILE"
 grep -A 20 "PID USER" "${DATA_DIR}/top_output.txt" | grep -v "PID USER" | \
 head -10 | awk '{print $9"% - "$12}' | sort -nr | head -5 >> "$REPORT_FILE"
fi
echo "" >> "$REPORT_FILE"

# Analyze I/O statistics
echo "DISK I/O ANALYSIS:" >> "$REPORT_FILE"
echo "------------------" >> "$REPORT_FILE"
if [ -f "${DATA_DIR}/iostat_output.txt" ]; then
 # Extract average I/O wait times
 grep -E "^[a-z]" "${DATA_DIR}/iostat_output.txt" | \
 awk '{if(NF>10) {util+=$NF; count++}} END {if(count>0) printf "Average Disk Utilization: %.2f%%\n", util/count}' >> "$REPORT_FILE"

 # Find devices with high I/O wait
 echo "Devices with high I/O utilization:" >> "$REPORT_FILE"
 grep -E "^[a-z]" "${DATA_DIR}/iostat_output.txt" | \
 awk '{if(NF>10 && $NF>50) print $1": "$NF"%"}' | sort -u >> "$REPORT_FILE"
fi
echo "" >> "$REPORT_FILE"

# Analyze memory usage
echo "MEMORY USAGE ANALYSIS:" >> "$REPORT_FILE"
echo "----------------------" >> "$REPORT_FILE"
if [ -f "${DATA_DIR}/memory_tracking.txt" ]; then
 # Calculate average memory usage
 awk '{used+=$3; total+=$2; count++} END {
 if(count>0) {
 avg_used=used/count;
 avg_total=total/count;
 usage_pct=(avg_used/avg_total)*100;
 printf "Average Memory Usage: %.0f MB / %.0f MB (%.1f%%)\n", avg_used, avg_total, usage_pct
 }
 }' "${DATA_DIR}/memory_tracking.txt" >> "$REPORT_FILE"
fi
echo "" >> "$REPORT_FILE"

# Analyze SAR data
echo "SYSTEM ACTIVITY ANALYSIS:" >> "$REPORT_FILE"
echo "-------------------------" >> "$REPORT_FILE"
if [ -f "${DATA_DIR}/sar_output.txt" ]; then
 # Extract network activity
 echo "Network Activity Summary:" >> "$REPORT_FILE"
 grep -E "eth0|ens|enp" "${DATA_DIR}/sar_output.txt" | \
 awk '{rx+=$5; tx+=$6; count++} END {
 if(count>0) printf "Average RX: %.2f KB/s, TX: %.2f KB/s\n", rx/count, tx/count
 }' >> "$REPORT_FILE"
fi
echo "" >> "$REPORT_FILE"

echo "Analysis completed. Report saved to: $REPORT_FILE"
cat "$REPORT_FILE"
