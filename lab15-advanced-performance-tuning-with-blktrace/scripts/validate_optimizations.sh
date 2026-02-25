# scripts/validate_optimizations.sh
#!/bin/bash
DEVICE=${1:-sda}
TEST_DIR="/opt/blktrace-lab"

echo "=== COMPREHENSIVE PERFORMANCE VALIDATION ==="
echo "Device: /dev/$DEVICE"
echo "Test directory: $TEST_DIR"
echo "Timestamp: $(date)"

# Function to run performance test
run_performance_test() {
  local test_name="$1"
  local trace_prefix="$2"

  echo -e "\n--- $test_name ---"

  # Start tracing
  blktrace -d /dev/$DEVICE -o $trace_prefix &
  TRACE_PID=$!

  sleep 1

  # Sequential read test
  echo "Sequential read (64KB blocks):"
  dd if=$TEST_DIR/test_100mb.dat of=/dev/null bs=64k 2>&1 | grep -E "(copied|MB/s|GB/s)"

  # Sequential write test
  echo "Sequential write (64KB blocks):"
  dd if=/dev/zero of=$TEST_DIR/temp_write.dat bs=64k count=1000 2>&1 | grep -E "(copied|MB/s|GB/s)"

  # Mixed I/O test
  echo "Mixed I/O test:"
  (
    dd if=$TEST_DIR/test_100mb.dat of=/dev/null bs=4k &
    dd if=/dev/zero of=$TEST_DIR/temp_mixed.dat bs=4k count=2000 &
    wait
  ) 2>&1 | grep -E "(copied|MB/s|GB/s)" | tail -2

  # Stop tracing
  sleep 2
  kill $TRACE_PID 2>/dev/null
  wait $TRACE_PID 2>/dev/null

  # Parse trace
  blkparse -i $trace_prefix -o ${trace_prefix}_parsed.txt 2>/dev/null

  if [ -f "${trace_prefix}_parsed.txt" ]; then
    total_ops=$(wc -l < ${trace_prefix}_parsed.txt)
    read_ops=$(grep -c " R " ${trace_prefix}_parsed.txt)
    write_ops=$(grep -c " W " ${trace_prefix}_parsed.txt)

    echo "Trace summary:"
    echo " Total operations: $total_ops"
    echo " Read operations: $read_ops"
    echo " Write operations: $write_ops"

    # Calculate average I/O size
    avg_size=$(awk '/[RW]/ {sum+=$10; count++} END {if(count>0) print int(sum/count)}' ${trace_prefix}_parsed.txt)
    echo " Average I/O size: ${avg_size} bytes"
  fi

  # Cleanup
  rm -f $TEST_DIR/temp_write.dat $TEST_DIR/temp_mixed.dat
}

# Record current system state
echo "=== CURRENT SYSTEM CONFIGURATION ==="
echo "I/O Scheduler: $(cat /sys/block/$DEVICE/queue/scheduler)"
echo "Queue depth: $(cat /sys/block/$DEVICE/queue/nr_requests)"
echo "Read-ahead: $(cat /sys/block/$DEVICE/queue/read_ahead_kb)KB"

# Run optimized performance test
run_performance_test "OPTIMIZED CONFIGURATION TEST" "trace_optimized"

# Generate comprehensive report
echo -e "\n=== OPTIMIZATION IMPACT ANALYSIS ==="
if [ -f "trace_baseline_parsed.txt" ] && [ -f "trace_optimized_parsed.txt" ]; then
  echo "Comparing baseline vs optimized configuration:"

  baseline_ops=$(wc -l < trace_baseline_parsed.txt)
  optimized_ops=$(wc -l < trace_optimized_parsed.txt)

  echo "Operations - Baseline: $baseline_ops, Optimized: $optimized_ops"

  if [ $baseline_ops -gt 0 ] && [ $optimized_ops -gt 0 ]; then
    improvement=$((optimized_ops * 100 / baseline_ops - 100))
    if [ $improvement -gt 0 ]; then
      echo "Performance improvement: +${improvement}% more operations"
    else
      echo "Performance change: ${improvement}% operations"
    fi
  fi
fi

# System resource usage during test
echo -e "\n=== SYSTEM RESOURCE USAGE ==="
echo "Current load average: $(uptime | awk -F'load average:' '{print $2}')"
echo "Memory usage:"
free -h | grep -E "(Mem|Swap)"

echo -e "\n=== RECOMMENDATIONS ==="
echo "Based on the analysis, consider the following:"
echo "1. Monitor these settings under production workload"
echo "2. Adjust queue depth based on storage type (SSD vs HDD)"
echo "3. Fine-tune read-ahead for your specific access patterns"
echo "4. Consider workload-specific I/O scheduler selection"
