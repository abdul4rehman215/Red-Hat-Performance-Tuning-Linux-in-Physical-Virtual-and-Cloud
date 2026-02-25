#!/bin/bash
# Lab 02 - Setting Up Performance Monitoring Tools
# Commands Executed During Lab (Sequential)

# ------------------------------
# Task 1: Update System + Verify OS Version
# ------------------------------

sudo dnf update -y
cat /etc/redhat-release

# ------------------------------
# Task 1: Install Core Monitoring Tools
# ------------------------------

sudo dnf install -y procps-ng
sudo dnf install -y sysstat
sudo dnf install -y dstat
sudo dnf install -y perf

which top vmstat iostat sar dstat perf

# ------------------------------
# Task 1: Enable System Activity Data Collection (sysstat)
# ------------------------------

sudo systemctl enable sysstat
sudo systemctl start sysstat
sudo systemctl status sysstat

# ------------------------------
# Task 1: Verify Tool Versions
# ------------------------------

top -v
vmstat -V
iostat -V
sar -V
dstat --version
perf --version

# ------------------------------
# Task 2: Initial Performance Tests
# ------------------------------

# top tests
top -b -n 5
top -d 2
top -u root
top -o %MEM

# vmstat tests
vmstat
vmstat 2 10
vmstat -S M 2 5
vmstat -s

# iostat tests
iostat
iostat 3 5
iostat -x 2 5
iostat -x sda 2 5
iostat -m 2 5

# sar tests
sar -u
sar -r
sar -n DEV
sar -d
sar -u -r -d 2 10

# dstat tests
dstat
dstat -cdnm
dstat --top-cpu --top-mem
dstat -cdnm 2 10
dstat -cdnm --output /tmp/dstat.log 2 10
ls -la /tmp/dstat.log

# perf tests
perf list
sudo perf record -a sleep 10
sudo perf report
sudo perf top
sudo perf record -e cycles -a sleep 5

# ------------------------------
# Task 3: Generate Load + Collect Baselines
# ------------------------------

# CPU load
yes > /dev/null &
CPU_PID=$!
echo $CPU_PID

# memory load
dd if=/dev/zero of=/tmp/memory_test bs=1M count=100

# disk I/O load
dd if=/dev/zero of=/tmp/disk_test bs=1M count=500

# cleanup + stop load
rm -f /tmp/memory_test /tmp/disk_test
kill $CPU_PID
jobs

# ------------------------------
# Task 3: Collect Baseline Logs
# ------------------------------

mkdir -p ~/performance_logs

sar -u 60 5 > ~/performance_logs/cpu_baseline.log
sar -r 60 5 > ~/performance_logs/memory_baseline.log
iostat -x 60 5 > ~/performance_logs/disk_baseline.log
sar -n DEV 60 5 > ~/performance_logs/network_baseline.log

# ------------------------------
# Task 3: Create Monitoring Script + Run
# ------------------------------

nano ~/performance_monitor.sh
chmod +x ~/performance_monitor.sh
~/performance_monitor.sh 3

# ------------------------------
# Task 3: Analyze Collected Logs
# ------------------------------

ls -la ~/performance_logs/

echo "=== CPU Utilization Summary ==="
tail -n 10 ~/performance_logs/cpu_*.log

echo "=== Memory Usage Summary ==="
tail -n 10 ~/performance_logs/memory_*.log

echo "=== Disk I/O Summary ==="
tail -n 10 ~/performance_logs/disk_*.log

# ------------------------------
# Task 3: Create Dashboard Script
# ------------------------------

nano ~/performance_dashboard.sh
chmod +x ~/performance_dashboard.sh
echo "Dashboard script created. Run with: ~/performance_dashboard.sh"

# ------------------------------
# Troubleshooting Commands (Executed)
# ------------------------------

sudo dnf repolist
sudo dnf clean all
sudo dnf install -y procps-ng sysstat dstat perf

sudo perf top
echo 0 | sudo tee /proc/sys/kernel/perf_event_paranoid

sudo systemctl restart sysstat
sudo systemctl status sysstat
sudo /usr/lib64/sa/sa1

iostat 30 5
top -p $(pgrep -d',' httpd)

# ------------------------------
# Verification Commands
# ------------------------------

echo "Testing top..."
timeout 5 top -b -n 1 > /dev/null && echo "✓ top working"

echo "Testing vmstat..."
vmstat 1 2 > /dev/null && echo "✓ vmstat working"

echo "Testing iostat..."
iostat 1 2 > /dev/null && echo "✓ iostat working"

echo "Testing sar..."
sar -u 1 2 > /dev/null && echo "✓ sar working"

echo "Testing dstat..."
timeout 5 dstat 1 2 > /dev/null && echo "✓ dstat working"

echo "Testing perf..."
sudo perf list > /dev/null && echo "✓ perf working"
