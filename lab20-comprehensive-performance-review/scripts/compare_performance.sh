#!/bin/bash
echo "PERFORMANCE COMPARISON ANALYSIS"
echo "==============================="

# Find baseline and post-tuning directories
BASELINE_DIR=$(ls -1t /opt/performance-review/monitoring/ | tail -1)
POST_TUNING_DIR=$(ls -1t /opt/performance-review/ | grep "post_tuning" | head -1)

if [ -z "$BASELINE_DIR" ] || [ -z "$POST_TUNING_DIR" ]; then
 echo "Error: Could not find baseline or post-tuning data"
 echo "Baseline: $BASELINE_DIR"
 echo "Post-tuning: $POST_TUNING_DIR"
 exit 1
fi

echo "Comparing:"
echo "Baseline: /opt/performance-review/monitoring/$BASELINE_DIR"
echo "Post-tuning: /opt/performance-review/$POST_TUNING_DIR"
echo ""

# Create comparison report
COMPARISON_REPORT="/opt/performance-review/reports/performance_comparison_$(date +%Y%m%d_%H%M%S).txt"

cat > "$COMPARISON_REPORT" << REPORT_EOF
PERFORMANCE COMPARISON REPORT
============================
Generated: $(date)

BASELINE DATA (Before Tuning):
-----------------------------
REPORT_EOF

# Extract baseline metrics if available
if [ -f "/opt/performance-review/monitoring/$BASELINE_DIR/memory_tracking.txt" ]; then
 baseline_mem=$(tail -1 "/opt/performance-review/monitoring/$BASELINE_DIR/memory_tracking.txt" | \
 awk '{printf "%.1f", ($3/$2)*100}')
 echo "Memory Usage (last sample): ${baseline_mem}%" >> "$COMPARISON_REPORT"
fi

if [ -f "/opt/performance-review/monitoring/$BASELINE_DIR/top_output.txt" ]; then
 baseline_cpu=$(grep "Cpu(s)" "/opt/performance-review/monitoring/$BASELINE_DIR/top_output.txt" | \
 head -1 | awk '{print $2}' | sed 's/%us,//')
 echo "CPU Usage (first sample): ${baseline_cpu}%" >> "$COMPARISON_REPORT"
fi

# Add baseline disk utilization from iostat if available
if [ -f "/opt/performance-review/monitoring/$BASELINE_DIR/iostat_output.txt" ]; then
 baseline_disk=$(grep -E "^[a-z]" "/opt/performance-review/monitoring/$BASELINE_DIR/iostat_output.txt" | \
 awk '{if(NF>10){util+=$NF; count++}} END {if(count>0) printf "%.2f", util/count}')
 echo "Avg Disk Utilization: ${baseline_disk}%" >> "$COMPARISON_REPORT"
fi

cat >> "$COMPARISON_REPORT" << REPORT_EOF

POST-TUNING DATA (After Tuning):
-------------------------------
REPORT_EOF

# Extract post-tuning results
if [ -f "/opt/performance-review/$POST_TUNING_DIR/system_snapshot.txt" ]; then
 post_load=$(grep "Load average" "/opt/performance-review/$POST_TUNING_DIR/system_snapshot.txt" | cut -d: -f2- | xargs)
 echo "Load Average: $post_load" >> "$COMPARISON_REPORT"
 post_mem_line=$(grep "Memory usage" "/opt/performance-review/$POST_TUNING_DIR/system_snapshot.txt" | cut -d: -f2-)
 echo "Memory (snapshot): $post_mem_line" >> "$COMPARISON_REPORT"
 post_cpu_line=$(grep "CPU usage" "/opt/performance-review/$POST_TUNING_DIR/system_snapshot.txt" | cut -d: -f2-)
 echo "CPU (snapshot): $post_cpu_line" >> "$COMPARISON_REPORT"
fi

if [ -f "/opt/performance-review/$POST_TUNING_DIR/cpu_test.txt" ]; then
 echo "" >> "$COMPARISON_REPORT"
 echo "CPU Test Timing:" >> "$COMPARISON_REPORT"
 cat "/opt/performance-review/$POST_TUNING_DIR/cpu_test.txt" >> "$COMPARISON_REPORT"
fi

if [ -f "/opt/performance-review/$POST_TUNING_DIR/memory_test.txt" ]; then
 echo "" >> "$COMPARISON_REPORT"
 echo "Memory Test:" >> "$COMPARISON_REPORT"
 cat "/opt/performance-review/$POST_TUNING_DIR/memory_test.txt" >> "$COMPARISON_REPORT"
fi

if [ -f "/opt/performance-review/$POST_TUNING_DIR/io_test.txt" ]; then
 echo "" >> "$COMPARISON_REPORT"
 echo "Disk I/O Test:" >> "$COMPARISON_REPORT"
 cat "/opt/performance-review/$POST_TUNING_DIR/io_test.txt" >> "$COMPARISON_REPORT"
fi

if [ -f "/opt/performance-review/$POST_TUNING_DIR/network_test.txt" ]; then
 echo "" >> "$COMPARISON_REPORT"
 echo "Network Test:" >> "$COMPARISON_REPORT"
 cat "/opt/performance-review/$POST_TUNING_DIR/network_test.txt" >> "$COMPARISON_REPORT"
fi

cat >> "$COMPARISON_REPORT" << REPORT_EOF

TUNING CHANGES APPLIED:
----------------------
- vm.swappiness set to 10
- vm.dirty_ratio set to 15
- vm.dirty_background_ratio set to 5
- net.core.rmem_max set to 16777216
- net.core.wmem_max set to 16777216
- net.ipv4.tcp_window_scaling enabled

VALIDATION NOTES:
-----------------
- Baseline includes data captured during stress generation window (higher CPU and disk util expected)
- Post-tuning tests were run under low load to validate tuned baseline and improved responsiveness
- For production validation, repeat the same stress test after tuning and compare apples-to-apples.

END OF REPORT
REPORT_EOF

echo "Comparison report generated: $COMPARISON_REPORT"
echo ""
cat "$COMPARISON_REPORT"
