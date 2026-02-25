#!/bin/bash
# Lab 03 - Viewing Hardware Resources
# Commands Executed During Lab (Sequential)

# ------------------------------
# Task 1: CPU Analysis (lscpu)
# ------------------------------

lscpu
lscpu | grep -E "(MHz|GHz)"
lscpu | grep -i cache
lscpu | grep Flags

# ------------------------------
# Task 2: Memory Analysis (free + /proc)
# ------------------------------

free -h
free -h --wide
free -h -s 5 -c 3

cat /proc/meminfo | head -20
free | awk 'NR==2{printf "Memory Usage: %.2f%%\n", $3*100/$2}'
free -h | grep Swap
swapon --show

# ------------------------------
# Task 3: Storage Analysis (lsblk + df + iostat)
# ------------------------------

lsblk
lsblk -f
lsblk -h
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE,UUID
df -h
iostat -x 1 3

# ------------------------------
# Task 4: Hardware Inventory (lshw)
# ------------------------------

command -v lshw || echo "lshw not found"
sudo dnf install -y lshw

sudo lshw
sudo lshw -short

sudo lshw -class processor
sudo lshw -class memory
sudo lshw -class disk
sudo lshw -class network

# ------------------------------
# Task 4.2: Network Interface Checks
# ------------------------------

ip link show
ip addr show
ping -c 4 8.8.8.8

# ------------------------------
# Task 5: Real-Time Monitoring + htop install
# ------------------------------

top
htop
sudo dnf install -y htop
htop
uptime

# ------------------------------
# Task 5.2: System Report Script
# ------------------------------

nano system_report.sh
chmod +x system_report.sh
./system_report.sh

# ------------------------------
# Task 5.2: Resource Monitoring Script (CSV)
# ------------------------------

nano monitor_resources.sh
chmod +x monitor_resources.sh
./monitor_resources.sh

cat resource_log.csv

# ------------------------------
# Baseline Documentation
# ------------------------------

echo "=== HARDWARE RESOURCE BASELINE ===" > baseline_report.txt
echo "System: $(hostname)" >> baseline_report.txt
echo "Date: $(date)" >> baseline_report.txt
echo "" >> baseline_report.txt
echo "CPU: $(lscpu | grep 'Model name' | cut -d':' -f2 | xargs)" >> baseline_report.txt
echo "Total Memory: $(free -h | awk 'NR==2{print $2}')" >> baseline_report.txt
echo "Storage: $(lsblk | grep disk | wc -l) devices" >> baseline_report.txt
echo "Network: $(ip link show | grep -c '^[0-9]') interfaces" >> baseline_report.txt
cat baseline_report.txt
