#!/bin/bash
echo "=== Disk I/O Bottleneck Simulation ==="
echo "Creating intensive disk I/O operations..."
echo "Monitor with 'iotop' in another terminal (requires sudo)"
echo "Press Ctrl+C to stop"

# Create multiple I/O intensive processes
for i in {1..3}; do
 (while true; do
  dd if=/dev/zero of=/tmp/disktest_$i bs=1M count=100 2>/dev/null
  rm -f /tmp/disktest_$i
 done) &
done

trap 'kill $(jobs -p); echo "Disk I/O stress test stopped"; exit' INT
wait
