#!/bin/bash
echo "TCP Performance Test Script"
echo "=========================="
# Test local loopback performance
echo "Starting iperf3 server in background..."
iperf3 -s -D
sleep 2
echo "Running TCP throughput test..."
iperf3 -c localhost -t 10 -P 4
echo "Stopping iperf3 server..."
pkill iperf3
echo "Test completed."
