#!/bin/bash
echo "=== Performance Tuning Goals Demonstration ==="
echo "1. Throughput: Measuring work completed per second"
echo "2. Response Time: Measuring request-response latency"
echo "3. Resource Utilization: Monitoring system resources"
echo "4. Scalability: Testing under increasing load"
echo ""

# Function to measure throughput
measure_throughput() {
 echo "Measuring CPU throughput..."
 start_time=$(date +%s)

 # Perform CPU-intensive calculation
 for i in {1..10000}; do
  echo "scale=10; sqrt($i)" | bc -l > /dev/null 2>&1
 done

 end_time=$(date +%s)
 duration=$((end_time - start_time))
 throughput=$((10000 / duration))

 echo "Completed 10,000 calculations in $duration seconds"
 echo "Throughput: $throughput calculations per second"
 echo ""
}

# Function to measure response time
measure_response_time() {
 echo "Measuring file system response time..."
 for i in {1..5}; do
  start_time=$(date +%s.%N)
  dd if=/dev/zero of=/tmp/test_file_$i bs=1M count=10 2>/dev/null
  end_time=$(date +%s.%N)
  response_time=$(echo "$end_time - $start_time" | bc)
  echo "File creation $i response time: ${response_time}s"
  rm -f /tmp/test_file_$i
 done
 echo ""
}

# Execute demonstrations
measure_throughput
measure_response_time

echo "Use 'htop' in another terminal to observe resource utilization"
echo "Press Enter to continue..."
read
