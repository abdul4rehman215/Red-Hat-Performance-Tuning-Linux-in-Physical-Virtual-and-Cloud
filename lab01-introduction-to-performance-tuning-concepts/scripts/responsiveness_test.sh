#!/bin/bash
echo "=== System Responsiveness Testing ==="
echo ""

# Test file system responsiveness
test_filesystem_response() {
 echo "Testing filesystem responsiveness..."
 total_time=0
 iterations=10

 for i in $(seq 1 $iterations); do
  start_time=$(date +%s.%N)
  touch /tmp/response_test_$i
  echo "test data" > /tmp/response_test_$i
  cat /tmp/response_test_$i > /dev/null
  rm /tmp/response_test_$i
  end_time=$(date +%s.%N)

  iteration_time=$(echo "$end_time - $start_time" | bc)
  total_time=$(echo "$total_time + $iteration_time" | bc)
  echo " Iteration $i: ${iteration_time}s"
 done

 average_time=$(echo "scale=6; $total_time / $iterations" | bc)
 echo " Average filesystem response time: ${average_time}s"
 echo ""
}

# Test process creation responsiveness
test_process_response() {
 echo "Testing process creation responsiveness..."
 total_time=0
 iterations=5

 for i in $(seq 1 $iterations); do
  start_time=$(date +%s.%N)
  /bin/echo "Process test $i" > /dev/null
  end_time=$(date +%s.%N)

  iteration_time=$(echo "$end_time - $start_time" | bc)
  total_time=$(echo "$total_time + $iteration_time" | bc)
  echo " Iteration $i: ${iteration_time}s"
 done

 average_time=$(echo "scale=6; $total_time / $iterations" | bc)
 echo " Average process creation time: ${average_time}s"
 echo ""
}

# Test network responsiveness (localhost)
test_network_response() {
 echo "Testing network responsiveness (localhost)..."
 ping_result=$(ping -c 5 localhost 2>/dev/null | tail -1)
 if [ $? -eq 0 ]; then
  echo " $ping_result"
 else
  echo " Network test failed"
 fi
 echo ""
}

# Run all responsiveness tests
test_filesystem_response
test_process_response
test_network_response

echo "=== Responsiveness Testing Complete ==="
