#!/bin/bash
echo "=== Network Performance Monitor ==="
echo "Timestamp: $(date)"
echo
echo "=== Network Buffer Settings ==="
echo "net.core.rmem_max = $(sysctl -n net.core.rmem_max)"
echo "net.core.wmem_max = $(sysctl -n net.core.wmem_max)"
echo "net.core.rmem_default = $(sysctl -n net.core.rmem_default)"
echo "net.core.wmem_default = $(sysctl -n net.core.wmem_default)"
echo
echo "=== TCP Settings ==="
echo "net.ipv4.tcp_rmem = $(sysctl -n net.ipv4.tcp_rmem)"
echo "net.ipv4.tcp_wmem = $(sysctl -n net.ipv4.tcp_wmem)"
echo "net.ipv4.tcp_congestion_control = $(sysctl -n net.ipv4.tcp_congestion_control)"
echo
echo "=== Network Queue Settings ==="
echo "net.core.netdev_max_backlog = $(sysctl -n net.core.netdev_max_backlog)"
echo "net.core.somaxconn = $(sysctl -n net.core.somaxconn)"
echo
echo "=== Current Network Connections ==="
ss -tuln | head -10
echo
