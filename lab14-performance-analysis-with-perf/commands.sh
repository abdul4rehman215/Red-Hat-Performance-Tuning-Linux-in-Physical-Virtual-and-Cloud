#!/bin/bash
# Lab 14 - Performance Analysis with perf
# Commands Executed During Lab (Ubuntu 24.04.1)

# ============================================
# Task 1.1: Install and Verify perf Tools
# ============================================
which perf
sudo apt update
sudo apt install linux-tools-common linux-tools-generic linux-tools-$(uname -r)
perf --version

# ============================================
# Task 1.2: Create CPU-Intensive Test Program
# ============================================
mkdir ~/perf-lab
cd ~/perf-lab
nano cpu_intensive.c
gcc -o cpu_intensive cpu_intensive.c
ls -lh cpu_intensive cpu_intensive.c

# ============================================
# Task 1.3: Basic CPU Performance Monitoring
# ============================================
perf stat ./cpu_intensive
perf stat -e cycles,instructions,cache-references,cache-misses,branch-misses ./cpu_intensive

# ============================================
# Task 1.4: Advanced CPU Profiling
# ============================================
perf record -g ./cpu_intensive
perf report
perf report --stdio > cpu_analysis.txt
head -40 cpu_analysis.txt

# ============================================
# Task 1.5: Real-time CPU Monitoring
# ============================================
./cpu_intensive &
CPU_PID=$!
perf top -p $CPU_PID
perf top
kill $CPU_PID

# ============================================
# Task 2.1: Create Memory-Intensive Test Program
# ============================================
nano memory_test.c
gcc -o memory_test memory_test.c

# ============================================
# Task 2.2: Analyze Memory Performance
# ============================================
perf record -e cache-misses,cache-references,page-faults ./memory_test
perf report --stdio > memory_analysis.txt
head -35 memory_analysis.txt
perf stat -e cache-misses,cache-references,LLC-loads,LLC-load-misses,page-faults ./memory_test

# ============================================
# Task 2.3: Memory Bandwidth Analysis
# ============================================
perf stat -e cpu/mem-loads/,cpu/mem-stores/ ./memory_test
perf record -e cpu/mem-loads/,cpu/mem-stores/ -g ./memory_test
perf report --stdio --sort=symbol,dso > memory_bandwidth.txt
head -40 memory_bandwidth.txt

# ============================================
# Task 2.4: NUMA Memory Analysis
# ============================================
numactl --hardware
perf stat -e node-loads,node-load-misses,node-stores ./memory_test
perf list | grep -i node | head -20
perf record -e cache-misses,cache-references,page-faults ./memory_test
perf report --stdio > numa_analysis.txt
head -25 numa_analysis.txt

# ============================================
# Task 3.1: Create I/O-Intensive Test Program
# ============================================
nano io_test.c
gcc -o io_test io_test.c

# ============================================
# Task 3.2: Monitor I/O Performance
# ============================================
perf stat -e syscalls:sys_enter_read,syscalls:sys_enter_write,syscalls:sys_enter_open,syscalls:sys_enter_close ./io_test
perf record -e syscalls:sys_enter_read,syscalls:sys_enter_write,syscalls:sys_enter_open ./io_test
perf report --stdio > io_analysis.txt
head -40 io_analysis.txt

# ============================================
# Task 3.3: Block I/O Analysis
# ============================================
sudo perf record -e block:block_rq_issue,block:block_rq_complete ./io_test
sudo perf report --stdio > block_io_analysis.txt
head -50 block_io_analysis.txt
perf stat -e sched:sched_stat_iowait ./io_test

# ============================================
# Task 3.4: File System Performance
# ============================================
sudo perf record -e ext4:ext4_da_write_begin,ext4:ext4_da_write_end ./io_test
dd if=/dev/zero of=large_test_file bs=1M count=100
perf stat -e block:block_rq_issue,block:block_rq_complete dd if=/dev/zero of=large_test_file2 bs=1M count=100
rm -f large_test_file large_test_file2

# ============================================
# Task 4.1: Multi-Resource Test Application
# ============================================
nano comprehensive_test.c
gcc -pthread -o comprehensive_test comprehensive_test.c

# ============================================
# Task 4.2: Comprehensive Performance Profiling
# ============================================
perf record -g -e cycles,cache-misses,page-faults,syscalls:sys_enter_write,syscalls:sys_enter_read ./comprehensive_test
perf report --stdio > comprehensive_analysis.txt
head -60 comprehensive_analysis.txt
perf report --sort=symbol --stdio > function_analysis.txt
head -40 function_analysis.txt
perf script > perf_script_output.txt
ls -lh perf_script_output.txt

# ============================================
# Task 4.3: Bottleneck Identification
# ============================================
perf report --sort=overhead --stdio | head -20 > top_cpu_consumers.txt
cat top_cpu_consumers.txt

perf stat -e L1-dcache-loads,L1-dcache-load-misses,LLC-loads,LLC-load-misses ./comprehensive_test > cache_performance.txt
cat cache_performance.txt
perf stat -e L1-dcache-loads,L1-dcache-load-misses,LLC-loads,LLC-load-misses ./comprehensive_test > cache_performance.txt 2>&1
tail -40 cache_performance.txt

perf stat -e context-switches,cpu-migrations,sched:sched_switch ./comprehensive_test > scheduling_analysis.txt 2>&1
tail -50 scheduling_analysis.txt

# ============================================
# Task 4.4: Optimization Recommendations Script
# ============================================
nano analyze_performance.sh
chmod +x analyze_performance.sh
./analyze_performance.sh

# ============================================
# Troubleshooting: Permission + Missing Events + Data Size
# ============================================
echo 0 | sudo tee /proc/sys/kernel/perf_event_paranoid
sudo perf record -a -g ./cpu_intensive
perf list | head -30
perf stat -e cpu-cycles,instructions ./cpu_intensive

timeout 10 perf record -g ./memory_test
perf record -g -z ./cpu_intensive
