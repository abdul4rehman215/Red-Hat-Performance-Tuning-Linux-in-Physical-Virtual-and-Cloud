# scripts/performance_comparison.sh
#!/bin/bash
COMPARISON_FILE="performance_comparison.txt"
echo "=== NETWORK PERFORMANCE COMPARISON REPORT ===" > $COMPARISON_FILE
echo "Generated: $(date)" >> $COMPARISON_FILE
echo "" >> $COMPARISON_FILE

# Extract key metrics from test results
extract_throughput() {
  local file=$1
  local test_name=$2

  echo "=== $test_name ===" >> $COMPARISON_FILE

  if [ -f "$file" ]; then
    # Extract final throughput values
    grep "receiver" "$file" | tail -5 >> $COMPARISON_FILE
    echo "" >> $COMPARISON_FILE
  else
    echo "File $file not found" >> $COMPARISON_FILE
    echo "" >> $COMPARISON_FILE
  fi
}

# Compare baseline vs optimized results
extract_throughput "baseline_results.txt" "BASELINE PERFORMANCE"
extract_throughput "tcp_optimized_results.txt" "TCP BUFFER OPTIMIZED"
extract_throughput "comprehensive_results.txt" "FULLY OPTIMIZED"

# Calculate improvement percentages
echo "=== PERFORMANCE IMPROVEMENT ANALYSIS ===" >> $COMPARISON_FILE

# Extract baseline throughput (simplified extraction)
BASELINE_THROUGHPUT=$(grep "receiver" baseline_results.txt 2>/dev/null | head -1 | awk '{print $7}' | sed 's/Mbits\/sec//')
OPTIMIZED_THROUGHPUT=$(grep "receiver" comprehensive_results.txt 2>/dev/null | head -1 | awk '{print $7}' | sed 's/Mbits\/sec//')

if [ ! -z "$BASELINE_THROUGHPUT" ] && [ ! -z "$OPTIMIZED_THROUGHPUT" ]; then
  IMPROVEMENT=$(echo "scale=2; (($OPTIMIZED_THROUGHPUT - $BASELINE_THROUGHPUT) / $BASELINE_THROUGHPUT) * 100" | bc -l 2>/dev/null)
  echo "Baseline Throughput: ${BASELINE_THROUGHPUT} Mbps" >> $COMPARISON_FILE
  echo "Optimized Throughput: ${OPTIMIZED_THROUGHPUT} Mbps" >> $COMPARISON_FILE
  echo "Performance Improvement: ${IMPROVEMENT}%" >> $COMPARISON_FILE
else
  echo "Unable to calculate improvement percentage" >> $COMPARISON_FILE
fi

echo "" >> $COMPARISON_FILE

# System configuration summary
echo "=== APPLIED OPTIMIZATIONS SUMMARY ===" >> $COMPARISON_FILE
echo "1. TCP Buffer Sizes:" >> $COMPARISON_FILE
sysctl net.ipv4.tcp_rmem >> $COMPARISON_FILE
sysctl net.ipv4.tcp_wmem >> $COMPARISON_FILE
echo "" >> $COMPARISON_FILE

echo "2. Network Interface Settings:" >> $COMPARISON_FILE
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -1)
echo "Interface: $INTERFACE" >> $COMPARISON_FILE
ethtool -g $INTERFACE | grep -A2 "Current hardware settings" >> $COMPARISON_FILE
echo "" >> $COMPARISON_FILE

echo "3. Offload Features:" >> $COMPARISON_FILE
ethtool -k $INTERFACE | grep -E "(tcp-segmentation-offload|generic-segmentation-offload|generic-receive-offload)" >> $COMPARISON_FILE

echo "Performance comparison completed. Report saved to $COMPARISON_FILE"
