#!/bin/bash
echo "=== Network Performance Test ==="
# Test local network performance using nc (netcat)
echo "Testing local network throughput..."
# Start a simple server in background
nc -l -p 12345 > /dev/null &
SERVER_PID=$!
# Give server time to start
sleep 1
# Send data to test throughput
echo "Sending test data..."
dd if=/dev/zero bs=1M count=100 2>/dev/null | nc localhost 12345
# Clean up
kill $SERVER_PID 2>/dev/null
wait $SERVER_PID 2>/dev/null
echo "Network test completed."
# Show current network statistics
echo "=== Network Statistics ==="
cat /proc/net/dev | head -3
