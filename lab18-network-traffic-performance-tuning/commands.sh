#!/bin/bash
# Lab 18: Network Traffic Performance Tuning - commands.sh
# NOTE:
# - Run as root (or with sudo) because sysctl/service edits need privileges.
# - This script follows the same command sequence as the lab.
# - Some steps may vary by distro (RHEL/CentOS vs Ubuntu). This lab uses RHEL/CentOS style yum.
# - Backup files are created where applicable.

set -euo pipefail

echo "===== LAB 18: Network Traffic Performance Tuning (commands.sh) ====="
echo "Timestamp: $(date)"
echo

# -------------------------------
# Task 1: Adjust TCP Parameters
# -------------------------------
echo "=== Task 1.1: Examine Current TCP Settings ==="
cat /proc/sys/net/core/rmem_default
cat /proc/sys/net/core/rmem_max
cat /proc/sys/net/core/wmem_default
cat /proc/sys/net/core/wmem_max

cat /proc/sys/net/ipv4/tcp_window_scaling
cat /proc/sys/net/ipv4/tcp_congestion_control
cat /proc/sys/net/ipv4/tcp_available_congestion_control

echo "=== Baseline TCP Settings ===" > /tmp/tcp_baseline.log
echo "Date: $(date)" >> /tmp/tcp_baseline.log
echo "rmem_default: $(cat /proc/sys/net/core/rmem_default)" >> /tmp/tcp_baseline.log
echo "rmem_max: $(cat /proc/sys/net/core/rmem_max)" >> /tmp/tcp_baseline.log
echo "wmem_default: $(cat /proc/sys/net/core/wmem_default)" >> /tmp/tcp_baseline.log
echo "wmem_max: $(cat /proc/sys/net/core/wmem_max)" >> /tmp/tcp_baseline.log
echo "tcp_congestion_control: $(cat /proc/sys/net/ipv4/tcp_congestion_control)" >> /tmp/tcp_baseline.log
cat /tmp/tcp_baseline.log
echo

echo "=== Task 1.2: Configure TCP Buffer Sizes for High Throughput ==="
cp -f /etc/sysctl.conf /etc/sysctl.conf.backup || true

# Create config file (content same as lab; bbr may not exist on some kernels)
cat > /etc/sysctl.d/99-tcp-performance.conf << 'EOF'
# TCP Buffer Size Optimization for Large Data Transfers
# Increase default and maximum socket buffer sizes
net.core.rmem_default = 262144
net.core.rmem_max = 134217728
net.core.wmem_default = 262144
net.core.wmem_max = 134217728

# TCP memory allocation (min, default, max)
net.ipv4.tcp_rmem = 4096 262144 134217728
net.ipv4.tcp_wmem = 4096 262144 134217728

# Enable TCP window scaling
net.ipv4.tcp_window_scaling = 1

# Increase maximum backlog queue
net.core.netdev_max_backlog = 5000

# Enable TCP timestamps
net.ipv4.tcp_timestamps = 1

# Enable selective acknowledgments
net.ipv4.tcp_sack = 1

# Set congestion control to BBR (if available) or cubic
net.ipv4.tcp_congestion_control = bbr

# Increase maximum number of connections
net.core.somaxconn = 65535

# TCP keepalive settings
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_keepalive_intvl = 60
net.ipv4.tcp_keepalive_probes = 3
EOF

# Apply settings (may error if bbr key not present / not supported)
set +e
sysctl -p /etc/sysctl.d/99-tcp-performance.conf
APPLY_RC=$?
set -e

# Compatibility fix if congestion control/bbr is not supported
if [ $APPLY_RC -ne 0 ]; then
  echo
  echo "!!! sysctl returned non-zero (likely congestion control unsupported). Switching to cubic ..."
  sed -i 's/net.ipv4.tcp_congestion_control = bbr/net.ipv4.tcp_congestion_control = cubic/' /etc/sysctl.d/99-tcp-performance.conf
  sysctl -p /etc/sysctl.d/99-tcp-performance.conf
fi

echo "=== New TCP Settings ===" > /tmp/tcp_optimized.log
echo "Date: $(date)" >> /tmp/tcp_optimized.log
echo "rmem_default: $(cat /proc/sys/net/core/rmem_default)" >> /tmp/tcp_optimized.log
echo "rmem_max: $(cat /proc/sys/net/core/rmem_max)" >> /tmp/tcp_optimized.log
echo "wmem_default: $(cat /proc/sys/net/core/wmem_default)" >> /tmp/tcp_optimized.log
echo "wmem_max: $(cat /proc/sys/net/core/wmem_max)" >> /tmp/tcp_optimized.log
cat /tmp/tcp_optimized.log
echo

echo "=== Task 1.3: Test TCP Performance Improvements ==="
yum install -y iperf3 || true

cat > /tmp/tcp_test.sh << 'EOF'
#!/bin/bash
echo "TCP Performance Test Script"
echo "=========================="
echo "Starting iperf3 server in background..."
iperf3 -s -D
sleep 2
echo "Running TCP throughput test..."
iperf3 -c localhost -t 10 -P 4
echo "Stopping iperf3 server..."
pkill iperf3
echo "Test completed."
EOF
chmod +x /tmp/tcp_test.sh
/tmp/tcp_test.sh
echo

# -------------------------------
# Task 2: DNS Optimization
# -------------------------------
echo "=== Task 2.1: Analyze Current DNS Configuration ==="
cat /etc/resolv.conf || true
dig google.com | grep "Query time" || true

for i in {1..5}; do
  echo "Query $i:"
  time nslookup google.com || true
done
echo

echo "=== Install DNS tools (bind-utils) ==="
yum install -y bind-utils || true
echo

echo "=== Task 2.2: Configure Local DNS Caching (dnsmasq) ==="
# systemd-resolved often not present on RHEL/CentOS
systemctl status systemd-resolved || true

yum install -y dnsmasq || true

mkdir -p /etc/dnsmasq.d
cat > /etc/dnsmasq.d/dns-performance.conf << 'EOF'
# DNS Performance Settings
cache-size=10000
no-resolv
server=1.1.1.1
server=8.8.8.8
server=8.8.4.4
server=1.0.0.1
EOF

systemctl enable dnsmasq || true
systemctl start dnsmasq || true

# Backup resolv.conf before changing
cp -f /etc/resolv.conf /etc/resolv.conf.backup || true
cat > /etc/resolv.conf << 'EOF'
nameserver 127.0.0.1
EOF

dig google.com | grep "Query time" || true
dig google.com | grep "Query time" || true
echo

echo "=== Task 2.3: DNS over HTTPS via cloudflared (optional, as in lab) ==="
# Download cloudflared
wget -O /usr/local/bin/cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
chmod +x /usr/local/bin/cloudflared

cat > /etc/systemd/system/cloudflared.service << 'EOF'
[Unit]
Description=Cloudflare DNS over HTTPS proxy
After=network.target

[Service]
ExecStart=/usr/local/bin/cloudflared proxy-dns --port 5053 --upstream https://1.1.1.1/dns-query --upstream https://1.0.0.1/dns-query
Restart=always
User=nobody
Group=nobody

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start cloudflared
systemctl enable cloudflared

# Forward dnsmasq to DoH proxy
echo "server=127.0.0.1#5053" >> /etc/dnsmasq.d/dns-performance.conf
systemctl restart dnsmasq
echo

cat > /tmp/dns_monitor.sh << 'EOF'
#!/bin/bash
echo "DNS Performance Monitoring"
echo "========================="

DOMAINS=("google.com" "github.com" "stackoverflow.com" "redhat.com" "ubuntu.com")

echo "Testing DNS resolution times..."
for domain in "${DOMAINS[@]}"; do
  echo -n "Testing $domain: "
  dig +short +time=1 +tries=1 $domain > /dev/null
  if [ $? -eq 0 ]; then
    time_result=$(dig $domain | grep "Query time" | awk '{print $4}')
    echo "${time_result}ms"
  else
    echo "Failed"
  fi
done

echo ""
echo "DNS Cache Statistics:"
sudo systemctl status dnsmasq --no-pager | head -15
EOF
chmod +x /tmp/dns_monitor.sh
/tmp/dns_monitor.sh
echo

# -------------------------------
# Task 3: netstat + ss monitoring
# -------------------------------
echo "=== Task 3.1: Install net-tools and baseline monitoring ==="
yum install -y net-tools || true

cat > /tmp/network_monitor.sh << 'EOF'
#!/bin/bash
echo "Network Traffic Monitoring Report"
echo "================================="
echo "Generated on: $(date)"
echo ""

echo "1. Active Network Connections (netstat):"
echo "----------------------------------------"
netstat -tuln | head -20
echo ""

echo "2. Socket Statistics (ss):"
echo "-------------------------"
ss -tuln | head -20
echo ""

echo "3. TCP Connection States:"
echo "------------------------"
ss -tan state established | wc -l | xargs echo "ESTABLISHED connections:"
ss -tan state time-wait | wc -l | xargs echo "TIME-WAIT connections:"
ss -tan state close-wait | wc -l | xargs echo "CLOSE-WAIT connections:"
echo ""

echo "4. Network Interface Statistics:"
echo "-------------------------------"
cat /proc/net/dev | grep -E "(eth0|ens|enp)" | head -5
echo ""

echo "5. TCP Memory Usage:"
echo "-------------------"
cat /proc/net/sockstat
echo ""

echo "6. Network Buffer Usage:"
echo "-----------------------"
echo "Receive buffer: $(cat /proc/sys/net/core/rmem_default) (default), $(cat /proc/sys/net/core/rmem_max) (max)"
echo "Send buffer: $(cat /proc/sys/net/core/wmem_default) (default), $(cat /proc/sys/net/core/wmem_max) (max)"
echo ""

echo "7. Top Network Processes:"
echo "------------------------"
ss -tulpn | grep -E ":(80|443|22|53)" | head -10
EOF
chmod +x /tmp/network_monitor.sh

/tmp/network_monitor.sh > /tmp/network_baseline.log
cat /tmp/network_baseline.log
echo

echo "=== Task 3.2: Traffic analysis ==="
cat > /tmp/traffic_analysis.sh << 'EOF'
#!/bin/bash
echo "Network Traffic Analysis"
echo "======================="
echo "Analyzing connection patterns..."
echo ""

echo "1. Connections by State:"
echo "-----------------------"
ss -tan | awk 'NR>1 {print $1}' | sort | uniq -c | sort -nr
echo ""

echo "2. Most Active Ports:"
echo "--------------------"
ss -tuln | awk 'NR>1 {print $5}' | awk -F: '{print $NF}' | sort | uniq -c | sort -nr | head -10
echo ""

echo "3. Connection Distribution by Protocol:"
echo "--------------------------------------"
ss -tan | wc -l | xargs echo "TCP connections:"
ss -uan | wc -l | xargs echo "UDP connections:"
echo ""

echo "4. Network Interface Throughput:"
echo "-------------------------------"
for interface in $(ls /sys/class/net/ | grep -E "^(eth|ens|enp)"); do
  if [ -f "/sys/class/net/$interface/statistics/rx_bytes" ]; then
    rx_bytes=$(cat /sys/class/net/$interface/statistics/rx_bytes)
    tx_bytes=$(cat /sys/class/net/$interface/statistics/tx_bytes)
    echo "$interface: RX=$(($rx_bytes/1024/1024))MB, TX=$(($tx_bytes/1024/1024))MB"
  fi
done
echo ""

echo "5. TCP Retransmission Statistics:"
echo "--------------------------------"
cat /proc/net/netstat | grep TcpExt | tail -1 | tr ' ' '\n' | nl | head -25
EOF
chmod +x /tmp/traffic_analysis.sh
/tmp/traffic_analysis.sh
echo

echo "=== Task 3.3: Dynamic Traffic Optimization ==="
cat > /tmp/optimize_traffic.sh << 'EOF'
#!/bin/bash
echo "Dynamic Network Traffic Optimization"
echo "==================================="

check_root() {
  if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
  fi
}

optimize_connections() {
  local conn_count=$(ss -tan state established | wc -l)
  echo "Current established connections: $conn_count"

  if [ $conn_count -gt 1000 ]; then
    echo "High connection count detected. Applying optimizations..."
    echo 65536 > /proc/sys/net/netfilter/nf_conntrack_max 2>/dev/null || true
    echo 30 > /proc/sys/net/ipv4/tcp_fin_timeout
    echo 1 > /proc/sys/net/ipv4/tcp_tw_reuse
    echo "High-load optimizations applied."
  else
    echo "Connection count is normal. Standard optimizations applied."
  fi
}

optimize_interfaces() {
  echo ""
  echo "Optimizing network interfaces..."
  for interface in $(ls /sys/class/net/ | grep -E "^(eth|ens|enp)"); do
    if [ -d "/sys/class/net/$interface" ]; then
      ifconfig $interface txqueuelen 10000 2>/dev/null || true
      echo "Optimized $interface queue length"
    fi
  done
}

monitor_and_adjust() {
  echo ""
  echo "Starting real-time monitoring (30 seconds)..."
  for i in {1..6}; do
    echo "Check $i/6:"
    time_wait_count=$(ss -tan state time-wait | wc -l)
    echo " TIME_WAIT connections: $time_wait_count"
    if [ $time_wait_count -gt 500 ]; then
      echo " High TIME_WAIT count detected. Adjusting parameters..."
      echo 1 > /proc/sys/net/ipv4/tcp_tw_reuse
    fi
    tcp_mem=$(cat /proc/net/sockstat | grep TCP | awk '{print $3}')
    echo " TCP sockets in use: $tcp_mem"
    sleep 5
  done
}

check_root
optimize_connections
optimize_interfaces
monitor_and_adjust

echo ""
echo "Traffic optimization completed."
echo "New settings will persist until reboot."
echo "To make permanent, add to /etc/sysctl.d/99-tcp-performance.conf"
EOF
chmod +x /tmp/optimize_traffic.sh
/tmp/optimize_traffic.sh
echo

echo "=== Network watchdog script (created as in lab; not started as service here) ==="
cat > /tmp/network_watchdog.sh << 'EOF'
#!/bin/bash
LOG_FILE="/var/log/network_performance.log"

while true; do
  timestamp=$(date)
  established=$(ss -tan state established | wc -l)
  time_wait=$(ss -tan state time-wait | wc -l)
  tcp_mem=$(cat /proc/net/sockstat | grep TCP | awk '{print $3}')

  echo "$timestamp - EST:$established TW:$time_wait MEM:$tcp_mem" >> $LOG_FILE

  if [ $established -gt 2000 ]; then
    echo "$timestamp - ALERT: High connection count ($established)" >> $LOG_FILE
  fi

  if [ $time_wait -gt 1000 ]; then
    echo "$timestamp - ALERT: High TIME_WAIT count ($time_wait)" >> $LOG_FILE
  fi

  sleep 60
done
EOF
chmod +x /tmp/network_watchdog.sh
echo "Watchdog created at /tmp/network_watchdog.sh"
echo

echo "=== Performance Validation Script ==="
cat > /tmp/performance_validation.sh << 'EOF'
#!/bin/bash
echo "Network Performance Validation"
echo "============================="
echo "1. TCP Performance Test:"
echo "-----------------------"
iperf3 -s -D
sleep 2
iperf3 -c localhost -t 10 -P 4
pkill iperf3

echo ""
echo "2. DNS Resolution Performance:"
echo "-----------------------------"
for i in {1..5}; do
  echo -n "Test $i: "
  time dig google.com +short > /dev/null
done

echo ""
echo "3. Connection Handling Test:"
echo "---------------------------"
echo "Current connection limits:"
ulimit -n
cat /proc/sys/net/core/somaxconn

echo ""
echo "4. Memory Usage:"
echo "---------------"
free -h
cat /proc/net/sockstat

echo ""
echo "Performance validation completed."
EOF
chmod +x /tmp/performance_validation.sh
/tmp/performance_validation.sh
echo

echo "===== Lab 18 commands.sh completed successfully ====="
