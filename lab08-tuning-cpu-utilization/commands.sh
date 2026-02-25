#!/bin/bash
# Lab 08: Tuning CPU Utilization - commands executed (Ubuntu 20.04+)
# User: toor

# -------------------------------
# Task 1: Examine baseline scheduler + CPU info
# -------------------------------
cat /sys/block/sda/queue/scheduler
lsblk
cat /sys/block/nvme0n1/queue/scheduler

sysctl -a | grep sched | head -20
cat /proc/schedstat
lscpu
cat /proc/cpuinfo | grep processor | wc -l

# -------------------------------
# Task 1.2: Install monitoring tools and baseline monitoring
# -------------------------------
sudo apt update && sudo apt install -y htop stress-ng sysstat

# (interactive) htop
htop

# baseline disk i/o snapshot (stopped with Ctrl+C)
iostat -x 1

# -------------------------------
# Task 1.2/1.4: Create + run CPU stress test script
# -------------------------------
nano cpu_stress_test.sh
chmod +x cpu_stress_test.sh
./cpu_stress_test.sh

# -------------------------------
# Task 1.3: Scheduler tuning + persistence
# -------------------------------
sysctl kernel.sched_min_granularity_ns
sysctl kernel.sched_wakeup_granularity_ns
sysctl kernel.sched_migration_cost_ns
sysctl kernel.sched_latency_ns

sysctl -a | grep sched > /tmp/original_sched_settings.txt
head -5 /tmp/original_sched_settings.txt

sudo sysctl kernel.sched_min_granularity_ns=1000000
sudo sysctl kernel.sched_wakeup_granularity_ns=2000000
sudo sysctl kernel.sched_migration_cost_ns=250000
sudo sysctl kernel.sched_latency_ns=6000000

sudo nano /etc/sysctl.conf
tail -n 8 /etc/sysctl.conf

sysctl kernel.sched_min_granularity_ns
sysctl kernel.sched_wakeup_granularity_ns
sysctl kernel.sched_migration_cost_ns
sysctl kernel.sched_latency_ns

# retest after tuning
./cpu_stress_test.sh

# compare metrics
vmstat 1 10
uptime

# -------------------------------
# Task 2: CPU affinity + topology
# -------------------------------
lscpu -e
numactl --hardware
sudo apt install -y numactl
numactl --hardware

taskset -p $$
taskset -p 1

# -------------------------------
# Task 2.2: Create workload scripts
# -------------------------------
nano cpu_intensive.py
chmod +x cpu_intensive.py

nano memory_intensive.py
chmod +x memory_intensive.py

# -------------------------------
# Task 2.3: Run workloads with default affinity
# -------------------------------
python3 cpu_intensive.py 60 &
PID1=$!
python3 cpu_intensive.py 60 &
PID2=$!
python3 memory_intensive.py 60 &
PID3=$!
echo "Started processes: $PID1, $PID2, $PID3"

# (interactive) observe CPU spread
htop

taskset -p $PID1
taskset -p $PID2
taskset -p $PID3

wait $PID1 $PID2 $PID3
echo "All processes completed"

# -------------------------------
# Task 2.4: Affinity optimization + monitoring
# -------------------------------
nano manage_affinity.sh
chmod +x manage_affinity.sh
source manage_affinity.sh

echo "=== Starting Optimized Workload ==="

taskset -c 0,1 python3 cpu_intensive.py 60 &
PID1=$!
echo "CPU-intensive task 1 (PID: $PID1) bound to cores 0,1"

taskset -c 2,3 python3 cpu_intensive.py 60 &
PID2=$!
echo "CPU-intensive task 2 (PID: $PID2) bound to cores 2,3"

taskset -c 0-3 python3 memory_intensive.py 60 &
PID3=$!
echo "Memory-intensive task (PID: $PID3) can use all cores"

echo ""
echo "=== Verifying Affinity Settings ==="
taskset -p $PID1
taskset -p $PID2
taskset -p $PID3

nano monitor_performance.sh
chmod +x monitor_performance.sh

for i in {1..6}; do
  echo "=== Monitoring Round $i ==="
  ./monitor_performance.sh
  sleep 10
done

wait $PID1 $PID2 $PID3
echo "All optimized processes completed"

# -------------------------------
# Task 2.5: Dynamic affinity adjustment
# -------------------------------
nano dynamic_affinity.sh
chmod +x dynamic_affinity.sh
./dynamic_affinity.sh

# -------------------------------
# Task 3.1: Comprehensive test framework
# -------------------------------
nano cpu_performance_test.sh
chmod +x cpu_performance_test.sh
./cpu_performance_test.sh

# -------------------------------
# Task 3.2: Web server simulation tests
# -------------------------------
nano web_server_sim.py
chmod +x web_server_sim.py

echo "=== Test 1: Default Configuration ==="
python3 web_server_sim.py 4 30
sleep 5

echo "=== Test 2: With CPU Affinity ==="
taskset -c 0-3 python3 web_server_sim.py 4 30
sleep 5

echo "=== Test 3: Optimized Core Assignment ==="
taskset -c 0,2 python3 web_server_sim.py 4 30

# -------------------------------
# Task 3.3: Generate analysis report
# -------------------------------
which bc
nano analyze_performance.sh
chmod +x analyze_performance.sh
./analyze_performance.sh

# -------------------------------
# Task 3.4: Optimization profiles script
# -------------------------------
nano optimization_profiles.sh
chmod +x optimization_profiles.sh

./optimization_profiles.sh show

echo "Testing latency profile..."
./optimization_profiles.sh latency
python3 cpu_intensive.py 20

echo "Testing throughput profile..."
./optimization_profiles.sh throughput
python3 cpu_intensive.py 20

echo "Applying balanced profile..."
./optimization_profiles.sh balanced

# -------------------------------
# Troubleshooting commands used in lab
# -------------------------------
sudo -v
ls -la /proc/sys/kernel/sched_*
uname -r

ps aux | grep python3
ps -eLf | grep python3

sudo mkdir -p /sys/fs/cgroup/cpuset/myapp
mount | grep cgroup

vmstat 1 10
pidstat -w 1 5
sudo sysctl kernel.sched_migration_cost_ns=5000000

top -bn1 | head -20
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

sudo sync && sudo echo 3 > /proc/sys/vm/drop_caches
echo 3 | sudo tee /proc/sys/vm/drop_caches
