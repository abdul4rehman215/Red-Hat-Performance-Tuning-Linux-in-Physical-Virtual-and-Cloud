# scripts/disk-analysis.sh
#!/bin/bash
# Disk I/O Performance Analysis Script

echo "=== Disk I/O Performance Analysis ==="
echo "Date: $(date)"
echo

# Current disk I/O activity
echo "Current Disk I/O Activity:"
sar -d 1 3
echo

echo "=== Disk Utilization Summary ==="
sar -d | tail -5
echo

echo "=== High Disk Utilization Periods ==="
# Find periods with high disk utilization
sar -d | awk '$NF > 50 {print "High disk utilization:", $1, $2, "Util:", $NF"%"}'
echo

echo "=== Disk Transfer Rate Analysis ==="
sar -d | awk 'NR>3 && $3+$4 > 100 {print "High transfer rate:", $1, $2, "Read+Write:", $3+$4, "KB/s"}'
echo

echo "=== Average Wait Time Analysis ==="
sar -d | awk 'NR>3 && $10 > 10 {print "High wait time:", $1, $2, "Await:", $10, "ms"}'
