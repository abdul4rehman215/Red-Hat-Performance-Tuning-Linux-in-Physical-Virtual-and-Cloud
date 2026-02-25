#!/bin/bash
# Real-time Performance Dashboard
# Press Ctrl+C to exit

while true; do
 clear
 echo "=========================================="
 echo " SYSTEM PERFORMANCE DASHBOARD"
 echo "=========================================="
 echo "Timestamp: $(date)"
 echo ""

 echo "--- CPU Usage ---"
 top -bn1 | grep "Cpu(s)" | awk '{print $2 $3 $4 $5 $6 $7 $8}'
 echo ""

 echo "--- Memory Usage ---"
 free -h | grep -E "Mem|Swap"
 echo ""

 echo "--- Disk Usage ---"
 df -h | head -n 5
 echo ""

 echo "--- Load Average ---"
 uptime
 echo ""

 echo "--- Top 5 CPU Processes ---"
 ps aux --sort=-%cpu | head -n 6
 echo ""

 echo "Press Ctrl+C to exit..."
 sleep 5
done
