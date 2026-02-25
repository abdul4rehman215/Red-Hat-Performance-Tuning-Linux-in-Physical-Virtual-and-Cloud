#!/bin/bash
# Lab 05 - Applying Tuned Profiles for Optimization
# Commands Executed During Lab (Sequential)

# ------------------------------
# Task 1: Verify tuned installation + service
# ------------------------------

rpm -qa | grep tuned
systemctl status tuned

sudo systemctl start tuned
sudo systemctl enable tuned

# ------------------------------
# Task 1.2: Explore profiles
# ------------------------------

tuned-adm list
tuned-adm active
tuned-adm recommend

# ------------------------------
# Task 1.3: Examine current system configuration
# ------------------------------

cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

# Lab command as-is (expected to fail on NVMe-only system)
cat /sys/block/sda/queue/scheduler

# Identify actual disks on this VM
lsblk
cat /sys/block/nvme0n1/queue/scheduler

# Check key kernel parameters (already tuned in earlier lab)
sysctl vm.swappiness
sysctl kernel.sched_min_granularity_ns
sysctl net.core.rmem_max

# ------------------------------
# Task 2: Install monitoring tools (if needed)
# ------------------------------

sudo yum install -y sysstat htop iotop

# ------------------------------
# Task 2.2: Create baseline monitoring script
# ------------------------------

nano ~/performance_monitor.sh
chmod +x ~/performance_monitor.sh

# ------------------------------
# Task 2.3: Collect baseline + confirm active profile
# ------------------------------

~/performance_monitor.sh "baseline"
echo "Current active profile:"
tuned-adm active

# ------------------------------
# Task 3: Apply balanced profile + verify + collect data
# ------------------------------

sudo tuned-adm profile balanced
tuned-adm active
tuned-adm verify

~/performance_monitor.sh "balanced"

echo "=== Changes after applying balanced profile ==="
echo "CPU Governor:"
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo "I/O Scheduler:"
cat /sys/block/nvme0n1/queue/scheduler
echo "Key parameters:"
sysctl vm.swappiness

# Stress test script + run
nano ~/stress_test.sh
chmod +x ~/stress_test.sh
~/stress_test.sh "balanced"

# ------------------------------
# Task 4: Apply throughput-performance profile + verify + collect data
# ------------------------------

sudo tuned-adm profile throughput-performance
tuned-adm active
tuned-adm verify

~/performance_monitor.sh "throughput-performance"

echo "=== Changes after applying throughput-performance profile ==="
echo "CPU Governor:"
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo "I/O Scheduler:"
cat /sys/block/nvme0n1/queue/scheduler
echo "Key parameters:"
sysctl vm.swappiness
sysctl kernel.sched_min_granularity_ns

# Stress test
~/stress_test.sh "throughput-performance"

# Compare tail sections
echo "=== Comparing results ==="
echo "Balanced profile results:"
tail -10 ~/stress_results_balanced.log
echo "Throughput-performance profile results:"
tail -10 ~/stress_results_throughput-performance.log

# ------------------------------
# Task 5: Apply virtual-guest profile + verify + collect data
# ------------------------------

sudo tuned-adm profile virtual-guest
tuned-adm active
tuned-adm verify

~/performance_monitor.sh "virtual-guest"

echo "=== Changes after applying virtual-guest profile ==="
echo "CPU Governor:"
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo "I/O Scheduler:"
cat /sys/block/nvme0n1/queue/scheduler
echo "Virtual machine specific parameters:"
sysctl vm.swappiness
sysctl vm.dirty_ratio

# Stress test
~/stress_test.sh "virtual-guest"

# ------------------------------
# Task 5: Comparison script
# ------------------------------

nano ~/compare_profiles.sh
chmod +x ~/compare_profiles.sh
~/compare_profiles.sh

# ------------------------------
# Task 6: Inspect profile configs
# ------------------------------

echo "=== Balanced Profile Configuration ==="
cat /usr/lib/tuned/balanced/tuned.conf

echo "=== Throughput-Performance Profile Configuration ==="
cat /usr/lib/tuned/throughput-performance/tuned.conf

echo "=== Virtual-Guest Profile Configuration ==="
cat /usr/lib/tuned/virtual-guest/tuned.conf

# ------------------------------
# Task 6.2: Create and apply custom profile
# ------------------------------

sudo mkdir -p /etc/tuned/custom-lab-profile
sudo tee /etc/tuned/custom-lab-profile/tuned.conf << 'EOF'
[main]
summary=Custom Lab Profile for Educational Purposes
include=balanced
[cpu]
governor=performance
energy_perf_bias=performance
[vm]
transparent_hugepages=never
[sysctl]
vm.swappiness=10
kernel.sched_min_granularity_ns=10000000
net.core.rmem_max=134217728
net.core.wmem_max=134217728
EOF

sudo tuned-adm profile custom-lab-profile
tuned-adm active
tuned-adm verify

~/performance_monitor.sh "custom-lab-profile"
~/stress_test.sh "custom-lab-profile"

# Update compare script to include custom profile + re-run
sed -i 's/virtual-guest/virtual-guest custom-lab-profile/' ~/compare_profiles.sh
~/compare_profiles.sh

# ------------------------------
# Task 7.1: Generate summary report
# ------------------------------

nano ~/performance_analysis.sh
chmod +x ~/performance_analysis.sh
~/performance_analysis.sh
cat ~/tuned_performance_report.txt

# ------------------------------
# Task 7.2: Real-time monitor (interactive)
# ------------------------------

nano ~/realtime_monitor.sh
chmod +x ~/realtime_monitor.sh
~/realtime_monitor.sh balanced 30

# ------------------------------
# Task 8.1: Troubleshoot script
# ------------------------------

nano ~/tuned_troubleshoot.sh
chmod +x ~/tuned_troubleshoot.sh
~/tuned_troubleshoot.sh

# ------------------------------
# Task 8.2: Profile switch test
# ------------------------------

nano ~/profile_switch_test.sh
chmod +x ~/profile_switch_test.sh
~/profile_switch_test.sh

# ------------------------------
# Task 8.3: Best practices checklist
# ------------------------------

nano ~/tuned_best_practices.sh
chmod +x ~/tuned_best_practices.sh
~/tuned_best_practices.sh
