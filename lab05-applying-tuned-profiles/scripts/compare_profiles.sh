#!/bin/bash
echo "=== Tuned Profile Performance Comparison ==="
echo "Date: $(date)"
echo ""
for profile in balanced throughput-performance virtual-guest custom-lab-profile; do
  echo "=== $profile Profile Results ==="
  if [ -f ~/stress_results_${profile}.log ]; then
    echo "Load averages during test:"
    grep "Load:" ~/stress_results_${profile}.log
    echo ""
    echo "CPU usage patterns:"
    grep "Cpu(s)" ~/stress_results_${profile}.log
    echo ""
    echo "Memory usage patterns:"
    grep -A1 "Memory usage:" ~/stress_results_${profile}.log | grep "Mem"
    echo ""
  else
    echo "No results file found for $profile"
  fi
  echo "----------------------------------------"
done
