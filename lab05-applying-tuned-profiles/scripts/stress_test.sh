#!/bin/bash
PROFILE_NAME=$1
DURATION=30
echo "Running stress test for profile: $PROFILE_NAME"
echo "Test duration: $DURATION seconds"

# Start monitoring in background
(
 for i in {1..6}; do
   echo "=== Monitoring iteration $i ==="
   echo "Time: $(date)"
   echo "Load: $(uptime | awk -F'load average:' '{print $2}')"
   echo "CPU usage:"
   top -bn1 | grep "Cpu(s)" | head -1
   echo "Memory usage:"
   free -h | grep Mem
   echo "---"
   sleep 5
 done
) > ~/stress_results_${PROFILE_NAME}.log &

# Run CPU stress test
echo "Starting CPU stress test..."
timeout $DURATION bash -c 'while true; do :; done' &
CPU_PID=$!

# Run I/O stress test
echo "Starting I/O stress test..."
timeout $DURATION bash -c 'while true; do dd if=/dev/zero of=/tmp/testfile bs=1M count=100 2>/dev/null; rm -f /tmp/testfile; done' &
IO_PID=$!

# Wait for tests to complete
wait $CPU_PID
wait $IO_PID

echo "Stress test completed for profile: $PROFILE_NAME"
echo "Results saved in: ~/stress_results_${PROFILE_NAME}.log"
