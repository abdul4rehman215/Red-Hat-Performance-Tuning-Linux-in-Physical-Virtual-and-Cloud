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
