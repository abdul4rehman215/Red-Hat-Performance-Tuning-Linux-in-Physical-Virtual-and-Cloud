#!/bin/bash
# Lab 12 - Network Utilization Tuning
# Commands Executed During Lab (Server + Client)

# ============================================
# CLIENT VM (ip-172-31-10-202) — Baseline Info
# ============================================

ip addr show
ip -s link show

ifconfig -a
sudo apt-get update -y
sudo apt-get install net-tools -y
ifconfig -a

sysctl net.core.rmem_max
sysctl net.core.wmem_max
sysctl net.core.rmem_default
sysctl net.core.wmem_default
sysctl net.ipv4.tcp_rmem
sysctl net.ipv4.tcp_wmem
sysctl -a | grep -E "(net.core|net.ipv4.tcp)" | head -20

INTERFACE=$(ip route | grep default | awk '{print $5}' | head -1)
echo "Primary interface: $INTERFACE"

ethtool $INTERFACE
ethtool -g $INTERFACE
ethtool -k $INTERFACE

# ============================================
# SERVER VM (ip-172-31-10-201) — iperf3 Server
# ============================================

sudo apt-get install iperf3 -y
iperf3 -s -p 5001

# ============================================
# CLIENT VM (ip-172-31-10-202) — iperf3 Client
# ============================================

sudo apt-get install iperf3 -y
SERVER_IP="172.31.20.10"
iperf3 -c $SERVER_IP -p 5001 -t 30

mkdir -p ~/network_tuning_results
cd ~/network_tuning_results

echo "=== BASELINE PERFORMANCE TEST ===" > baseline_results.txt
date >> baseline_results.txt
echo "TCP Throughput Test:" >> baseline_results.txt
iperf3 -c $SERVER_IP -p 5001 -t 30 >> baseline_results.txt
echo "UDP Throughput Test:" >> baseline_results.txt
iperf3 -c $SERVER_IP -p 5001 -u -b 1G -t 30 >> baseline_results.txt
echo "Latency Test:" >> baseline_results.txt
ping -c 100 $SERVER_IP >> baseline_results.txt

ls -lh baseline_results.txt

# ============================================
# TCP Buffer Analysis + Calculation Scripts
# ============================================

nano ~/check_tcp_buffers.sh
chmod +x ~/check_tcp_buffers.sh
~/check_tcp_buffers.sh

nano ~/calculate_buffers.sh
chmod +x ~/calculate_buffers.sh
~/calculate_buffers.sh

# ============================================
# Apply sysctl Optimizations (TCP buffers, BBR)
# ============================================

sudo cp /etc/sysctl.conf /etc/sysctl.conf.backup

nano ~/network_optimization.conf
sudo cp ~/network_optimization.conf /etc/sysctl.d/99-network-performance.conf
sudo sysctl -p /etc/sysctl.d/99-network-performance.conf

echo "=== Verifying TCP Buffer Changes ==="
~/check_tcp_buffers.sh

echo ""
echo "Available congestion control algorithms:"
sysctl net.ipv4.tcp_available_congestion_control
echo "Current congestion control algorithm:"
sysctl net.ipv4.tcp_congestion_control

# ============================================
# Post TCP Optimization Tests
# ============================================

cd ~/network_tuning_results

echo "=== POST TCP BUFFER OPTIMIZATION TEST ===" > tcp_optimized_results.txt
date >> tcp_optimized_results.txt
echo "TCP Throughput Test (Optimized Buffers):" >> tcp_optimized_results.txt
iperf3 -c $SERVER_IP -p 5001 -t 30 -w 1M >> tcp_optimized_results.txt
echo "TCP Parallel Streams Test:" >> tcp_optimized_results.txt
iperf3 -c $SERVER_IP -p 5001 -t 30 -P 4 >> tcp_optimized_results.txt

ls -lh tcp_optimized_results.txt

# ============================================
# NIC Analysis + Optimization (ethtool)
# ============================================

INTERFACE=$(ip route | grep default | awk '{print $5}' | head -1)

nano ~/analyze_interface.sh
chmod +x ~/analyze_interface.sh
~/analyze_interface.sh > ~/network_tuning_results/interface_analysis.txt
ls -lh ~/network_tuning_results/interface_analysis.txt

echo "Current ring buffer settings for $INTERFACE:"
ethtool -g $INTERFACE

nano ~/optimize_ring_buffers.sh
chmod +x ~/optimize_ring_buffers.sh
~/optimize_ring_buffers.sh

nano ~/optimize_offloads.sh
chmod +x ~/optimize_offloads.sh
~/optimize_offloads.sh

nano ~/optimize_coalescing.sh
chmod +x ~/optimize_coalescing.sh
~/optimize_coalescing.sh

# ============================================
# Persist ethtool Settings with systemd service
# ============================================

nano ~/ethtool_persistent.sh
chmod +x ~/ethtool_persistent.sh
sudo cp ~/ethtool_persistent.sh /usr/local/bin/

sudo tee /etc/systemd/system/network-optimization.service > /dev/null << 'EOF'
[Unit]
Description=Network Interface Optimization
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/ethtool_persistent.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable network-optimization.service
sudo systemctl start network-optimization.service
sudo systemctl status network-optimization.service --no-pager

# ============================================
# Advanced iperf3 Testing (Comprehensive)
# ============================================

cd ~/network_tuning_results

nano ~/comprehensive_test.sh
chmod +x ~/comprehensive_test.sh
~/comprehensive_test.sh
ls -lh comprehensive_results.txt

# ============================================
# System Resource Monitoring During Tests
# ============================================

nano ~/monitor_performance.sh
chmod +x ~/monitor_performance.sh

sudo yum install sysstat -y 2>/dev/null || sudo apt-get install sysstat -y 2>/dev/null

~/monitor_performance.sh

# ============================================
# Latency and Jitter Analysis
# ============================================

nano ~/latency_analysis.sh
chmod +x ~/latency_analysis.sh
~/latency_analysis.sh
ls -lh latency_analysis.txt

# ============================================
# Performance Comparison Report + bc install
# ============================================

nano ~/performance_comparison.sh
chmod +x ~/performance_comparison.sh

sudo apt-get install bc -y

~/performance_comparison.sh
ls -lh performance_comparison.txt

# ============================================
# Troubleshooting / Verification Commands
# ============================================

sudo -v
sysctl -a | grep net.ipv4.tcp_rmem
uname -r
cat /proc/version

ethtool -k $INTERFACE | grep "fixed"
ip link show $INTERFACE
lspci | grep -i network
