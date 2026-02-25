#!/bin/bash
# Lab 01 - Introduction to Performance Tuning Concepts
# Commands Executed During Lab (Sequential)

# ------------------------------
# Task 1: Baseline System Info
# ------------------------------

uname -a
lscpu
free -h
df -h
uptime

# ------------------------------
# Task 1: Create Lab Workspace + Baseline Report
# ------------------------------

mkdir -p ~/performance_lab
cd ~/performance_lab
pwd

echo "=== System Baseline Report ===" > baseline_report.txt
echo "Date: $(date)" >> baseline_report.txt
echo "" >> baseline_report.txt

echo "CPU Information:" >> baseline_report.txt
lscpu | grep -E "Model name|CPU\(s\)|Thread|Core" >> baseline_report.txt
echo "" >> baseline_report.txt

echo "Memory Information:" >> baseline_report.txt
free -h >> baseline_report.txt
echo "" >> baseline_report.txt

echo "Disk Usage:" >> baseline_report.txt
df -h >> baseline_report.txt
echo "" >> baseline_report.txt

echo "Current Load:" >> baseline_report.txt
uptime >> baseline_report.txt

cat baseline_report.txt

# ------------------------------
# Task 1: Install Tools + Performance Demo Script
# ------------------------------

sudo yum install -y stress-ng htop iotop nethogs 2>/dev/null || sudo apt-get install -y stress-ng htop iotop nethogs 2>/dev/null

nano performance_demo.sh
chmod +x performance_demo.sh
./performance_demo.sh

# ------------------------------
# Task 2: Monitoring Tools + Enable sysstat
# ------------------------------

sudo yum install -y sysstat iftop 2>/dev/null || sudo apt-get install -y sysstat iftop 2>/dev/null

sudo systemctl enable sysstat 2>/dev/null || echo "sysstat service configuration may vary by distribution"

# ------------------------------
# Task 2: Monitoring Script
# ------------------------------

nano system_monitor.sh
chmod +x system_monitor.sh
./system_monitor.sh

head -40 system_performance.log

# ------------------------------
# Task 2: Bottleneck Simulation Scripts
# ------------------------------

nano cpu_bottleneck.sh
nano memory_bottleneck.sh
nano disk_bottleneck.sh

chmod +x cpu_bottleneck.sh memory_bottleneck.sh disk_bottleneck.sh

# ------------------------------
# Task 2: Bottleneck Analysis Script
# ------------------------------

nano analyze_bottlenecks.sh
chmod +x analyze_bottlenecks.sh
./analyze_bottlenecks.sh

# ------------------------------
# Task 3: Responsiveness Testing
# ------------------------------

nano responsiveness_test.sh
chmod +x responsiveness_test.sh
./responsiveness_test.sh

# ------------------------------
# Task 3: Scalability Testing
# ------------------------------

nano scalability_test.sh
chmod +x scalability_test.sh
./scalability_test.sh

# ------------------------------
# Task 3: Generate Consolidated Performance Report
# ------------------------------

nano generate_performance_report.sh
chmod +x generate_performance_report.sh
./generate_performance_report.sh

head -40 performance_tuning_report.txt

# ------------------------------
# Verification Commands
# ------------------------------

ls -la *.sh
ls -la *.log *.txt
uptime && free -h && df -h
