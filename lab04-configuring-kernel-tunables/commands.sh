#!/bin/bash
# Lab 04 - Configuring Kernel Tunables
# Commands Executed During Lab (Sequential)

# ------------------------------
# Task 1: Explore /proc/sys + sysctl basics
# ------------------------------

cd /proc/sys
ls -la

ls /proc/sys/vm/
ls /proc/sys/net/
ls /proc/sys/kernel/

sysctl -a | head -20
sysctl vm.
sysctl vm.swappiness

# ------------------------------
# Task 2: Memory parameters (baseline + tuning)
# ------------------------------

free -h

sysctl vm.swappiness
cat /proc/sys/vm/swappiness

sysctl vm.dirty_ratio
sysctl vm.dirty_background_ratio
sysctl vm.dirty_writeback_centisecs

# Create baseline script (via nano)
nano /tmp/memory_monitor.sh
chmod +x /tmp/memory_monitor.sh
/tmp/memory_monitor.sh

# Swappiness tuning
sysctl vm.swappiness
sudo sysctl vm.swappiness=10
sysctl vm.swappiness
echo 10 | sudo tee /proc/sys/vm/swappiness

# Dirty page tuning
sysctl vm.dirty_ratio vm.dirty_background_ratio
sudo sysctl vm.dirty_ratio=15
sudo sysctl vm.dirty_background_ratio=5
sudo sysctl vm.dirty_writeback_centisecs=500
sysctl vm.dirty_ratio vm.dirty_background_ratio vm.dirty_writeback_centisecs

# VFS cache pressure tuning
sysctl vm.vfs_cache_pressure
sudo sysctl vm.vfs_cache_pressure=150
sysctl vm.vfs_cache_pressure

# Validate memory state after tuning
/tmp/memory_monitor.sh

# Memory allocation test
nano /tmp/memory_test.sh
chmod +x /tmp/memory_test.sh
/tmp/memory_test.sh

# ------------------------------
# Task 3: Network parameters (baseline + tuning)
# ------------------------------

sysctl net.core.rmem_max
sysctl net.core.wmem_max
sysctl net.core.rmem_default
sysctl net.core.wmem_default

sysctl net.ipv4.tcp_rmem
sysctl net.ipv4.tcp_wmem
sysctl net.ipv4.tcp_congestion_control

sysctl net.core.netdev_max_backlog

# Network baseline monitor script
nano /tmp/network_monitor.sh
chmod +x /tmp/network_monitor.sh
/tmp/network_monitor.sh

# Network buffer tuning
sudo sysctl net.core.rmem_max=16777216
sudo sysctl net.core.wmem_max=16777216
sudo sysctl net.core.rmem_default=262144
sudo sysctl net.core.wmem_default=262144
sysctl net.core.rmem_max net.core.wmem_max net.core.rmem_default net.core.wmem_default

# TCP buffer tuning
sudo sysctl net.ipv4.tcp_rmem="4096 87380 16777216"
sudo sysctl net.ipv4.tcp_wmem="4096 65536 16777216"
sysctl net.ipv4.tcp_rmem net.ipv4.tcp_wmem

# Queue tuning + window scaling
sudo sysctl net.core.netdev_max_backlog=5000
sudo sysctl net.core.somaxconn=1024
sudo sysctl net.ipv4.tcp_window_scaling=1
sysctl net.core.netdev_max_backlog net.core.somaxconn net.ipv4.tcp_window_scaling

# Re-check network state after tuning
/tmp/network_monitor.sh

# Local network throughput test (nc)
nano /tmp/network_test.sh
chmod +x /tmp/network_test.sh
/tmp/network_test.sh

# Install netcat implementation used in RHEL
sudo dnf install -y nmap-ncat
/tmp/network_test.sh

# ------------------------------
# Task 4: Persist tuning via sysctl.d
# ------------------------------

ls -la /etc/sysctl.conf
cat /etc/sysctl.conf

# Create persistent config (used tee/EOF in lab)
sudo tee /etc/sysctl.d/99-performance-tuning.conf << 'EOF'
# Performance Tuning Configuration
# Created for Lab 4: Configuring Kernel Tunables
# Memory Management Parameters
vm.swappiness = 10
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
vm.dirty_writeback_centisecs = 500
vm.vfs_cache_pressure = 150
# Network Performance Parameters
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.rmem_default = 262144
net.core.wmem_default = 262144
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.core.netdev_max_backlog = 5000
net.core.somaxconn = 1024
net.ipv4.tcp_window_scaling = 1
# Additional optimizations
kernel.sched_migration_cost_ns = 5000000
kernel.sched_autogroup_enabled = 0
EOF

cat /etc/sysctl.d/99-performance-tuning.conf

sudo sysctl -p /etc/sysctl.d/99-performance-tuning.conf
sysctl vm.swappiness vm.dirty_ratio net.core.rmem_max net.ipv4.tcp_rmem
sudo sysctl --system

# ------------------------------
# Task 4.4: Validation script
# ------------------------------

nano /tmp/validate_config.sh
chmod +x /tmp/validate_config.sh
/tmp/validate_config.sh

# ------------------------------
# Task 5: Analysis + rollback + monitoring setup
# ------------------------------

nano /tmp/performance_analysis.sh
chmod +x /tmp/performance_analysis.sh
/tmp/performance_analysis.sh

nano /tmp/rollback_tuning.sh
chmod +x /tmp/rollback_tuning.sh
echo "Rollback script created at /tmp/rollback_tuning.sh"

nano /tmp/continuous_monitor.sh
chmod +x /tmp/continuous_monitor.sh
echo "Continuous monitoring script created."
echo "Run with: /tmp/continuous_monitor.sh"

# ------------------------------
# Troubleshooting commands executed
# ------------------------------

sudo -l
sudo sysctl vm.swappiness=10
ls /proc/sys/vm/swappiness

find /proc/sys -name "*swappiness*" 2>/dev/null
sysctl -a | grep vm | head -20

sudo sysctl -p /etc/sysctl.d/99-performance-tuning.conf
sudo sysctl --system 2>&1 | grep -i error
ls -la /etc/sysctl.d/99-performance-tuning.conf

/tmp/rollback_tuning.sh
sudo sysctl vm.swappiness=60
sudo sysctl vm.dirty_ratio=20
sudo sysctl -p /etc/sysctl.d/99-performance-tuning.conf > /dev/null

# ------------------------------
# Security-related checks
# ------------------------------

sysctl net.ipv4.tcp_syncookies
sysctl vm.overcommit_memory
sysctl net.ipv4.tcp_syncookies net.ipv4.icmp_echo_ignore_broadcasts

# ------------------------------
# Final validation steps
# ------------------------------

echo "=== Final Lab Validation ==="
echo "1. Running configuration validation..."
/tmp/validate_config.sh
echo -e "\n2. Running performance analysis..."
/tmp/performance_analysis.sh
echo -e "\n3. Testing parameter persistence..."
sudo sysctl --system > /dev/null 2>&1
echo "✓ Configuration loaded successfully"

# Completion report
nano /tmp/lab_completion_report.txt
echo "✓ Lab completion report created: /tmp/lab_completion_report.txt"
cat /tmp/lab_completion_report.txt
