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
