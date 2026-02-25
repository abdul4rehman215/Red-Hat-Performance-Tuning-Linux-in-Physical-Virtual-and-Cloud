# scripts/cpu-analysis.sh
#!/bin/bash
# CPU Performance Analysis Script

echo "=== CPU Performance Analysis ==="
echo "Date: $(date)"
echo

# Current CPU utilization
echo "Current CPU Utilization (5 samples):"
sar -u 1 5
echo

echo "=== CPU Utilization Summary for Today ==="
sar -u | tail -1
echo

echo "=== Peak CPU Usage Times ==="
sar -u | grep -v "Average" | grep -v "Linux" | grep -v "^$" | sort -k3 -nr | head -5
echo

echo "=== CPU Load Average ==="
sar -q | tail -5
