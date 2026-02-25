#!/bin/bash
echo "Starting CPU stress test..."
echo "Cores available: $(nproc)"
echo "Starting stress test on all cores for 30 seconds"
stress-ng --cpu $(nproc) --timeout 30s --metrics-brief
