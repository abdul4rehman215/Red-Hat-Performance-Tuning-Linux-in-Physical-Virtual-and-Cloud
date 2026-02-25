#!/bin/bash
# Performance testing framework
LOG_FILE="cpu_performance_results.log"
TEST_DURATION=30

log_message() {
  echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" | tee -a $LOG_FILE
}

run_baseline_test() {
  log_message "=== BASELINE TEST ==="
  log_message "System Information:"
  lscpu | grep -E "(Model name|CPU\(s\)|Thread|Core|Socket)" | tee -a $LOG_FILE

  log_message "Starting baseline CPU stress test"
  stress-ng --cpu $(nproc) --timeout ${TEST_DURATION}s --metrics-brief 2>&1 | tee -a $LOG_FILE
}

run_affinity_test() {
  log_message "=== AFFINITY OPTIMIZATION TEST ==="

  # Test 1: All processes on all cores (default)
  log_message "Test 1: Default affinity (all cores)"
  python3 cpu_intensive.py $TEST_DURATION &
  python3 cpu_intensive.py $TEST_DURATION &
  python3 memory_intensive.py $TEST_DURATION &
  wait

  sleep 5

  # Test 2: Optimized affinity
  log_message "Test 2: Optimized affinity"
  taskset -c 0,1 python3 cpu_intensive.py $TEST_DURATION &
  taskset -c 2,3 python3 cpu_intensive.py $TEST_DURATION &
  taskset -c 0-3 python3 memory_intensive.py $TEST_DURATION &
  wait
}

run_scheduler_test() {
  log_message "=== SCHEDULER OPTIMIZATION TEST ==="

  # Create mixed workload
  log_message "Running mixed workload with optimized scheduler"

  for i in {1..4}; do
    taskset -c $((i-1)) python3 cpu_intensive.py $TEST_DURATION &
  done

  wait
}

monitor_system_metrics() {
  log_message "=== SYSTEM METRICS COLLECTION ==="

  # Collect various metrics
  log_message "Load Average: $(uptime)"
  log_message "Memory Usage: $(free -h | grep Mem)"
  log_message "Context Switches: $(vmstat 1 2 | tail -1 | awk '{print $12}')"
  log_message "CPU Utilization: $(top -bn1 | grep 'Cpu(s)' | awk '{print $2}')"
}

# Main execution
log_message "Starting comprehensive CPU performance testing"
log_message "Test duration per scenario: ${TEST_DURATION} seconds"

run_baseline_test
sleep 10
run_affinity_test
sleep 10
run_scheduler_test
sleep 10
monitor_system_metrics

log_message "Performance testing completed. Results saved to $LOG_FILE"
