# scripts/comprehensive_test.sh
#!/bin/bash
SERVER_IP="172.31.20.10" # Replace with your server IP
RESULTS_FILE="comprehensive_results.txt"

echo "=== COMPREHENSIVE NETWORK PERFORMANCE TEST ===" > $RESULTS_FILE
echo "Test Date: $(date)" >> $RESULTS_FILE
echo "Server IP: $SERVER_IP" >> $RESULTS_FILE
echo "" >> $RESULTS_FILE

# Test 1: Single stream TCP throughput
echo "=== Test 1: Single Stream TCP Throughput ===" >> $RESULTS_FILE
iperf3 -c $SERVER_IP -p 5001 -t 60 -i 10 >> $RESULTS_FILE
echo "" >> $RESULTS_FILE

# Test 2: Multiple parallel streams
echo "=== Test 2: Multiple Parallel Streams (4 streams) ===" >> $RESULTS_FILE
iperf3 -c $SERVER_IP -p 5001 -t 60 -P 4 -i 10 >> $RESULTS_FILE
echo "" >> $RESULTS_FILE

# Test 3: Different window sizes
for window in 64K 128K 256K 512K 1M 2M; do
  echo "=== Test 3: TCP with ${window} window size ===" >> $RESULTS_FILE
  iperf3 -c $SERVER_IP -p 5001 -t 30 -w $window >> $RESULTS_FILE
  echo "" >> $RESULTS_FILE
done

# Test 4: UDP throughput at different rates
for rate in 100M 500M 1G; do
  echo "=== Test 4: UDP at ${rate} rate ===" >> $RESULTS_FILE
  iperf3 -c $SERVER_IP -p 5001 -u -b $rate -t 30 >> $RESULTS_FILE
  echo "" >> $RESULTS_FILE
done

# Test 5: Bidirectional test
echo "=== Test 5: Bidirectional Test ===" >> $RESULTS_FILE
iperf3 -c $SERVER_IP -p 5001 -t 30 --bidir >> $RESULTS_FILE
echo "" >> $RESULTS_FILE

# Test 6: Reverse mode test
echo "=== Test 6: Reverse Mode Test ===" >> $RESULTS_FILE
iperf3 -c $SERVER_IP -p 5001 -t 30 -R >> $RESULTS_FILE
echo "" >> $RESULTS_FILE

echo "Comprehensive testing completed. Results saved to $RESULTS_FILE"
