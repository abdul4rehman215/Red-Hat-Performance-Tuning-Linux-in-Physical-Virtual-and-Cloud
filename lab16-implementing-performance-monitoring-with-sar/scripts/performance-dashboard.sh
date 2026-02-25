# scripts/performance-dashboard.sh
#!/bin/bash
# Real-time Performance Dashboard

# Function to display dashboard
show_dashboard() {
 clear
 echo "=========================================="
 echo " REAL-TIME PERFORMANCE DASHBOARD"
 echo "=========================================="
 echo "Hostname: $(hostname)"
 echo "Time: $(date)"
 echo "Uptime: $(uptime | awk -F'up ' '{print $2}' | awk -F',' '{print $1}')"
 echo

 echo "CPU UTILIZATION:"
 echo "================"
 sar -u 1 1 | tail -1
 echo

 echo "MEMORY USAGE:"
 echo "============="
 free -h
 echo

 echo "DISK I/O (Last 5 seconds):"
 echo "=========================="
 sar -d 1 1 | grep -E "(DEV|Average)" | head -6
 echo

 echo "NETWORK ACTIVITY (Last 5 seconds):"
 echo "=================================="
 sar -n DEV 1 1 | grep -E "(IFACE|Average)" | grep -v lo
 echo

 echo "TOP PROCESSES:"
 echo "=============="
 ps aux --sort=-%cpu | head -6
 echo

 echo "Press Ctrl+C to exit..."
}

# Main loop
while true; do
 show_dashboard
 sleep 5
done
