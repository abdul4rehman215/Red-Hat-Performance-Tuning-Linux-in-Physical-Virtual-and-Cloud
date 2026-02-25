#!/bin/bash
echo "=== Performance Comparison: With vs Without cgroups ==="
echo
# Test function
run_performance_test() {
 local test_name="$1"
 local use_cgroup="$2"

 echo "Running $test_name..."

 # CPU test
 echo " CPU Test (calculating pi):"
 start_time=$(date +%s.%N)

 if [ "$use_cgroup" = "true" ]; then
  (echo "scale=2000; 4*a(1)" | bc -l > /dev/null) &
  test_pid=$!
  echo $test_pid | sudo tee /sys/fs/cgroup/lab6_demo/cgroup.procs > /dev/null
  wait $test_pid
 else
  echo "scale=2000; 4*a(1)" | bc -l > /dev/null
 fi

 end_time=$(date +%s.%N)
 cpu_time=$(echo "$end_time - $start_time" | bc)
 echo " Time: ${cpu_time}s"

 # Memory allocation test
 echo " Memory Test (allocating 50MB):"
 start_time=$(date +%s.%N)

 if [ "$use_cgroup" = "true" ]; then
  (python3 -c "
data = []
for i in range(50):
 data.append(bytearray(1024*1024))
import time; time.sleep(1)
") &
  test_pid=$!
  echo $test_pid | sudo tee /sys/fs/cgroup/lab6_demo/cgroup.procs > /dev/null
  wait $test_pid
 else
  python3 -c "
data = []
for i in range(50):
 data.append(bytearray(1024*1024))
import time; time.sleep(1)
"
 fi

 end_time=$(date +%s.%N)
 mem_time=$(echo "$end_time - $start_time" | bc)
 echo " Time: ${mem_time}s"

 echo
}
# Run tests
run_performance_test "Test WITHOUT cgroups" "false"
run_performance_test "Test WITH cgroups" "true"
echo "Note: cgroup-limited processes should show longer execution times"
echo "due to resource constraints."
