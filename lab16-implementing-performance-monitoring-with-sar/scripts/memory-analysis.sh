# scripts/memory-analysis.sh
#!/bin/bash
# Memory Performance Analysis Script

echo "=== Memory Performance Analysis ==="
echo "Date: $(date)"
echo

# Current memory utilization
echo "Current Memory Utilization:"
sar -r 1 3
echo

echo "=== Memory Usage Summary ==="
sar -r | tail -1
echo

echo "=== Swap Usage Analysis ==="
sar -S | tail -5
echo

echo "=== Memory Pressure Indicators ==="
# Check for high memory utilization periods
sar -r | awk '$4 > 80 {print "High memory usage at", $1, "- Used:", $4"%"}'
echo

echo "=== Page Fault Statistics ==="
sar -B | tail -5
