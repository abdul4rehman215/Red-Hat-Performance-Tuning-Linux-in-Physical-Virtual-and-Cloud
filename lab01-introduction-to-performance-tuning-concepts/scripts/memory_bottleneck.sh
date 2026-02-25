#!/bin/bash
echo "=== Memory Bottleneck Simulation ==="
echo "Allocating memory to simulate memory pressure..."
echo "Monitor with 'free -h' in another terminal"
echo "Press Ctrl+C to stop"

# Use stress-ng to create memory pressure
stress-ng --vm 2 --vm-bytes 75% --timeout 300s &
STRESS_PID=$!

trap 'kill $STRESS_PID 2>/dev/null; echo "Memory stress test stopped"; exit' INT
wait $STRESS_PID
