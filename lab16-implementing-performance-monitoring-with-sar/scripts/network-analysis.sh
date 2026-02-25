# scripts/network-analysis.sh
#!/bin/bash
# Network Performance Analysis Script

echo "=== Network Performance Analysis ==="
echo "Date: $(date)"
echo

# Current network activity
echo "Current Network Activity:"
sar -n DEV 1 3
echo

echo "=== Network Interface Summary ==="
sar -n DEV | grep -E "(IFACE|Average)" | grep -v lo
echo

echo "=== High Network Utilization Periods ==="
# Find periods with high network activity (>1MB/s)
sar -n DEV | awk '$3+$4 > 1000 && $2 != "lo" {print "High network activity:", $1, $2, "RX+TX:", ($3+$4)/1024, "MB/s"}'
echo

echo "=== Network Error Analysis ==="
sar -n EDEV | grep -v "00:00:00" | grep -v "Average" | awk '$3+$4+$5+$6 > 0'
echo

echo "=== TCP Connection Statistics ==="
sar -n TCP | tail -5
