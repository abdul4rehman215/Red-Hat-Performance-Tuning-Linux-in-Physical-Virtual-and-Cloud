#!/bin/bash
# Lab 09: Memory Utilization Tuning - commands.sh
# Note: Some steps intentionally open interactive editors (nano). 

set -euo pipefail

echo "=== Lab 09: Memory Utilization Tuning ==="
echo "Started: $(date)"
echo

# -------------------------------
# Task 1: Baseline memory checks
# -------------------------------
echo "[Task 1] Baseline memory + swappiness + swap status"

free -h
cat /proc/meminfo | head -20
cat /proc/sys/vm/swappiness

swapon --show || true
cat /proc/swaps

# Baseline report file creation (as you did)
echo "=== Memory Baseline Report ===" > memory_baseline.txt
echo "Date: $(date)" >> memory_baseline.txt
echo "" >> memory_baseline.txt
echo "Memory Information:" >> memory_baseline.txt
free -h >> memory_baseline.txt
echo "" >> memory_baseline.txt
echo "Current swappiness: $(cat /proc/sys/vm/swappiness)" >> memory_baseline.txt
echo "" >> memory_baseline.txt
echo "Swap Information:" >> memory_baseline.txt
swapon --show >> memory_baseline.txt || true

cat memory_baseline.txt
echo

# -------------------------------
# Task 1.2: view vm params
# -------------------------------
echo "[Task 1.2] View vm.* parameters (sample)"

sysctl -a | grep vm | head -10
sysctl vm.swappiness
sysctl vm.vfs_cache_pressure
sysctl vm.dirty_ratio
echo

# -------------------------------
# Task 1.3: Modify swappiness
# -------------------------------
echo "[Task 1.3] Temporary swappiness change + persist in sysctl.conf"

sudo sysctl vm.swappiness=10
cat /proc/sys/vm/swappiness

echo 10 | sudo tee /proc/sys/vm/swappiness

sudo cp /etc/sysctl.conf /etc/sysctl.conf.backup
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
grep swappiness /etc/sysctl.conf || true
echo

# -------------------------------
# Script creation (nano steps)
# -------------------------------
echo "[Scripts] Create scripts via nano (interactive)"

echo "Opening nano to create memory_tune.sh ..."
nano memory_tune.sh
chmod +x memory_tune.sh
./memory_tune.sh
echo

# -------------------------------
# Task 2: Monitoring with free
# -------------------------------
echo "[Task 2.1] free command monitoring examples"

free -h
free -m
free -b
free -h -s 2 -c 5
echo

echo "Opening nano to create explain_free.sh ..."
nano explain_free.sh
chmod +x explain_free.sh
./explain_free.sh
echo

echo "Opening nano to create monitor_memory.sh ..."
nano monitor_memory.sh
chmod +x monitor_memory.sh
# (Created for later use; run if you want)
# ./monitor_memory.sh
echo

# -------------------------------
# Task 2.2: Monitoring with vmstat
# -------------------------------
echo "[Task 2.2] vmstat monitoring examples"

vmstat
vmstat 2 10
vmstat -S M 2 5
vmstat -s
echo

echo "Opening nano to create explain_vmstat.sh ..."
nano explain_vmstat.sh
chmod +x explain_vmstat.sh
./explain_vmstat.sh
echo

echo "Opening nano to create advanced_memory_monitor.sh ..."
nano advanced_memory_monitor.sh
chmod +x advanced_memory_monitor.sh
# (Created for later use; run if you want)
# ./advanced_memory_monitor.sh
echo

# -------------------------------
# Task 3: Memory load testing
# -------------------------------
echo "[Task 3.1] Install stress-ng + create stress scripts"

sudo apt update
sudo apt install -y stress-ng

echo "Opening nano to create simple_memory_stress.sh ..."
nano simple_memory_stress.sh
chmod +x simple_memory_stress.sh
# ./simple_memory_stress.sh   # optional run
echo

echo "Opening nano to create memory_performance_test.sh ..."
nano memory_performance_test.sh
chmod +x memory_performance_test.sh
# ./memory_performance_test.sh # optional run
echo

# -------------------------------
# Task 3.2: Swappiness comparison script
# -------------------------------
echo "[Task 3.2] Create swappiness comparison script"

echo "Opening nano to create swappiness_comparison.sh ..."
nano swappiness_comparison.sh
chmod +x swappiness_comparison.sh
# ./swappiness_comparison.sh  # optional run (takes time)
echo

# -------------------------------
# Task 3.3: Optimization + validation scripts
# -------------------------------
echo "[Task 3.3] Create optimize + validate scripts"

echo "Opening nano to create optimize_memory.sh ..."
nano optimize_memory.sh
chmod +x optimize_memory.sh
# ./optimize_memory.sh  # optional run (modifies sysctl.conf)
echo

echo "Opening nano to create validate_optimization.sh ..."
nano validate_optimization.sh
chmod +x validate_optimization.sh
# ./validate_optimization.sh # optional run (takes time)
echo

# -------------------------------
# Troubleshooting / swap enable (if needed)
# -------------------------------
echo "[Troubleshooting] Swap enable steps (only if swap was missing and you needed it)"

swapon --show || true

# Create swapfile (1G) for testing (only if needed)
# Uncomment if you want to replicate your lab steps:
# sudo fallocate -l 1G /swapfile
# sudo chmod 600 /swapfile
# sudo mkswap /swapfile
# sudo swapon /swapfile
# free -h

echo
echo "=== Lab 09 commands.sh completed ==="
echo "Finished: $(date)"
