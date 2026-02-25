#!/bin/bash
VALIDATION_LOG="optimization_validation_$(date +%Y%m%d_%H%M%S).log"

echo "Memory Optimization Validation"
echo "============================="
echo "Log file: $VALIDATION_LOG"

# Function to run performance test
run_performance_test() {
  local test_name=$1
  local duration=$2

  echo "Running $test_name..."

  {
    echo "=== $test_name ==="
    echo "Start time: $(date)"
    echo "Memory state before test:"
    free -h
    echo ""
  } >> $VALIDATION_LOG

  # Clear caches for consistent testing
  sudo sync
  echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null

  # Monitor system during test
  vmstat 1 $duration >> $VALIDATION_LOG &
  local vmstat_pid=$!

  # Create workload
  if command -v stress-ng >/dev/null 2>&1; then
    stress-ng --vm 2 --vm-bytes 50% --timeout ${duration}s > /dev/null 2>&1
  else
    for i in $(seq 1 $duration); do
      dd if=/dev/zero of=/dev/null bs=1M count=100 2>/dev/null &
      sleep 1
      killall dd 2>/dev/null
    done
  fi

  # Stop monitoring
  kill $vmstat_pid 2>/dev/null
  wait $vmstat_pid 2>/dev/null

  {
    echo ""
    echo "Memory state after test:"
    free -h
    echo "End time: $(date)"
    echo ""
  } >> $VALIDATION_LOG
}

# Run validation tests
run_performance_test "Baseline Performance Test" 30
sleep 10
run_performance_test "Memory Intensive Test" 60
sleep 10
run_performance_test "Final Validation Test" 30

# Generate performance summary
{
  echo "=== Performance Summary ==="
  echo "Generated: $(date)"
  echo ""
  echo "Current Memory Configuration:"
  echo " Swappiness: $(cat /proc/sys/vm/swappiness)"
  echo " VFS Cache Pressure: $(cat /proc/sys/vm/vfs_cache_pressure)"
  echo " Dirty Ratio: $(cat /proc/sys/vm/dirty_ratio)"
  echo ""
  echo "Average swap activity during tests:"
  grep -E "^ *[0-9]" $VALIDATION_LOG | awk '
  BEGIN { si_total=0; so_total=0; count=0 }
  { si_total+=$7; so_total+=$8; count++ }
  END {
    if(count>0) {
      printf " Average swap in: %.2f KB/s\n", si_total/count
      printf " Average swap out: %.2f KB/s\n", so_total/count
    }
  }'
} >> $VALIDATION_LOG

echo "Validation complete!"
echo "Results saved to: $VALIDATION_LOG"
echo ""
echo "Quick summary:"
tail -10 $VALIDATION_LOG
