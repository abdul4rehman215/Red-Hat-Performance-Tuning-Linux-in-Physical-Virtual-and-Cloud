#!/bin/bash
echo "Dynamic Network Traffic Optimization"
echo "==================================="

# Function to check if running as root
check_root() {
  if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
  fi
}

# Function to optimize based on connection count
optimize_connections() {
  local conn_count=$(ss -tan state established | wc -l)
  echo "Current established connections: $conn_count"

  if [ $conn_count -gt 1000 ]; then
    echo "High connection count detected. Applying optimizations..."

    # Increase connection tracking table size
    echo 65536 > /proc/sys/net/netfilter/nf_conntrack_max 2>/dev/null || true

    # Reduce TIME_WAIT timeout
    echo 30 > /proc/sys/net/ipv4/tcp_fin_timeout

    # Enable TCP reuse
    echo 1 > /proc/sys/net/ipv4/tcp_tw_reuse

    echo "High-load optimizations applied."
  else
    echo "Connection count is normal. Standard optimizations applied."
  fi
}

# Function to optimize based on interface utilization
optimize_interfaces() {
  echo ""
  echo "Optimizing network interfaces..."

  for interface in $(ls /sys/class/net/ | grep -E "^(eth|ens|enp)"); do
    if [ -d "/sys/class/net/$interface" ]; then
      # Increase interface queue length
      ifconfig $interface txqueuelen 10000 2>/dev/null || true
      echo "Optimized $interface queue length"
    fi
  done
}

# Function to monitor and adjust in real-time
monitor_and_adjust() {
  echo ""
  echo "Starting real-time monitoring (30 seconds)..."

  for i in {1..6}; do
    echo "Check $i/6:"

    # Check for high TIME_WAIT connections
    time_wait_count=$(ss -tan state time-wait | wc -l)
    echo " TIME_WAIT connections: $time_wait_count"

    if [ $time_wait_count -gt 500 ]; then
      echo " High TIME_WAIT count detected. Adjusting parameters..."
      echo 1 > /proc/sys/net/ipv4/tcp_tw_reuse
    fi

    # Check memory usage
    tcp_mem=$(cat /proc/net/sockstat | grep TCP | awk '{print $3}')
    echo " TCP sockets in use: $tcp_mem"

    sleep 5
  done
}

# Main execution
check_root
optimize_connections
optimize_interfaces
monitor_and_adjust

echo ""
echo "Traffic optimization completed."
echo "New settings will persist until reboot."
echo "To make permanent, add to /etc/sysctl.d/99-tcp-performance.conf"
