#!/bin/bash
echo "Network Performance Validation"
echo "============================="
echo "1. TCP Performance Test:"
echo "-----------------------"
# Start iperf3 server
iperf3 -s -D
sleep 2
# Run client test
iperf3 -c localhost -t 10 -P 4
# Stop server
pkill iperf3
echo ""
echo "2. DNS Resolution Performance:"
echo "-----------------------------"
for i in {1..5}; do
  echo -n "Test $i: "
  time dig google.com +short > /dev/null
done
echo ""
echo "3. Connection Handling Test:"
echo "---------------------------"
echo "Current connection limits:"
ulimit -n
cat /proc/sys/net/core/somaxconn
echo ""
echo "4. Memory Usage:"
echo "---------------"
free -h
cat /proc/net/sockstat
echo ""
echo "Performance validation completed."
