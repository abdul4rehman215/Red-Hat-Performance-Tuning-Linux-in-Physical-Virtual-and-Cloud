#!/bin/bash
echo "=== CPU Bottleneck Simulation ==="
echo "Creating CPU-intensive processes..."
echo "Monitor with 'htop' in another terminal"
echo "Press Ctrl+C to stop"

# Create multiple CPU-intensive processes
for i in {1..4}; do
 (while true; do echo "scale=5000; 4*a(1)" | bc -l > /dev/null; done) &
done

# Wait for user interrupt
trap 'kill $(jobs -p); echo "CPU stress test stopped"; exit' INT
wait
