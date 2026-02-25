# scripts/historical-analysis.sh
#!/bin/bash
# Historical Performance Trend Analysis

DAYS_BACK=7
REPORT_FILE="/tmp/historical-trends-$(date +%Y-%m-%d).txt"

echo "HISTORICAL PERFORMANCE TRENDS ANALYSIS" > $REPORT_FILE
echo "Analysis Period: Last $DAYS_BACK days" >> $REPORT_FILE
echo "Generated: $(date)" >> $REPORT_FILE
echo >> $REPORT_FILE

# Function to analyze trends for each day
analyze_daily_trends() {
 local day_offset=$1
 local analysis_date=$(date -d "$day_offset days ago" +%d)
 local sa_file="/var/log/sa/sa$analysis_date"

 if [ -f "$sa_file" ]; then
   echo "=== $(date -d "$day_offset days ago" +%Y-%m-%d) ===" >> $REPORT_FILE

   # CPU trends
   echo "CPU Average: $(sar -u -f $sa_file | tail -1 | awk '{print $3"%"}')" >> $REPORT_FILE

   # Memory trends
   echo "Memory Average: $(sar -r -f $sa_file | tail -1 | awk '{print $4"%"}')" >> $REPORT_FILE

   # Load average
   echo "Load Average: $(sar -q -f $sa_file | tail -1 | awk '{print $4}')" >> $REPORT_FILE

   echo >> $REPORT_FILE
 fi
}

# Analyze trends for the past week
echo "DAILY PERFORMANCE SUMMARY:" >> $REPORT_FILE
echo "=========================" >> $REPORT_FILE

for i in $(seq 0 $((DAYS_BACK-1))); do
 analyze_daily_trends $i
done

# Peak usage analysis
echo "PEAK USAGE ANALYSIS:" >> $REPORT_FILE
echo "===================" >> $REPORT_FILE

# Find peak CPU usage across all available data
echo "Peak CPU Usage Periods:" >> $REPORT_FILE

for sa_file in /var/log/sa/sa[0-9][0-9]; do
 if [ -f "$sa_file" ]; then
   sar -u -f $sa_file | grep -v "Average" | grep -v "Linux" | grep -v "^$" | \
   awk -v file="$sa_file" '$3 > 90 {print file, $1, "CPU:", $3"%"}' >> $REPORT_FILE
 fi
done

echo >> $REPORT_FILE
echo "Historical analysis completed: $REPORT_FILE"
