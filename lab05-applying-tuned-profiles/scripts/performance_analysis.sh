#!/bin/bash
REPORT_FILE="$HOME/tuned_performance_report.txt"

echo "=== Comprehensive Tuned Profile Performance Analysis ===" > "$REPORT_FILE"
echo "Generated on: $(date)" >> "$REPORT_FILE"
echo "System: $(uname -a)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "=== Profile Configuration Summary ===" >> "$REPORT_FILE"
for profile in balanced throughput-performance virtual-guest custom-lab-profile; do
  echo "--- $profile ---" >> "$REPORT_FILE"
  latest_file=$(ls -t "$HOME/tuned_performance_data/${profile}_"*.log 2>/dev/null | head -1)
  if [ -n "$latest_file" ]; then
    echo "CPU Governor: $(grep -A1 "=== CPU Governor ===" "$latest_file" | tail -1)" >> "$REPORT_FILE"
    echo "I/O Scheduler: $(grep -A1 "=== I/O Scheduler ===" "$latest_file" | tail -1)" >> "$REPORT_FILE"
    echo "vm.swappiness: $(grep "vm.swappiness" "$latest_file" | head -1)" >> "$REPORT_FILE"
  else
    echo "No log file found for $profile" >> "$REPORT_FILE"
  fi
  echo "" >> "$REPORT_FILE"
done

echo "=== Performance Test Results Summary ===" >> "$REPORT_FILE"
for profile in balanced throughput-performance virtual-guest custom-lab-profile; do
  echo "--- $profile Stress Test Results ---" >> "$REPORT_FILE"
  if [ -f "$HOME/stress_results_${profile}.log" ]; then
    echo "Average Load:" >> "$REPORT_FILE"
    grep "Load:" "$HOME/stress_results_${profile}.log" | awk -F': ' '{print $2}' >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
  else
    echo "No stress test log found for $profile" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
  fi
done

echo "Performance analysis report generated: $REPORT_FILE"
