#!/bin/bash
# Lab 13 - Tuning Virtualization Performance
# Commands Executed During Lab (Host + Guest)

# =========================================================
# Task 1.1: Analyze Current VM Configuration (Host)
# =========================================================
sudo virsh list --all
sudo virsh dumpxml vm-test1 | grep -E "(vcpu|memory)"
sudo virsh dominfo vm-test1

# =========================================================
# Task 1.2: Host CPU Topology Checks (Host)
# =========================================================
lscpu | grep -E "(CPU\(s\)|Thread|Core|Socket)"
cat /proc/cpuinfo | grep -E "(processor|physical id|core id)" | head -20

# =========================================================
# Task 1.2: Create performance VM (Host)
# =========================================================
nano configure_vcpu.sh
chmod +x configure_vcpu.sh

command -v virsh && command -v virt-install

./configure_vcpu.sh
sudo virsh list --all | grep performance-vm

# =========================================================
# Task 1.2: vCPU Pinning (Host)
# =========================================================
sudo virsh vcpupin performance-vm 0 0
sudo virsh vcpupin performance-vm 1 1
sudo virsh vcpupin performance-vm 2 2
sudo virsh vcpupin performance-vm 3 3
sudo virsh vcpuinfo performance-vm

# =========================================================
# Task 1.3: NUMA Memory Config + Hugepages (Host)
# =========================================================
nano memory_config.xml

cat /proc/meminfo | grep -i huge
echo 1024 | sudo tee /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
cat /proc/meminfo | grep -i huge

# =========================================================
# Task 1.3: Update VM memory settings via virsh edit (Host)
# =========================================================
nano update_memory.sh
chmod +x update_memory.sh
./update_memory.sh

# =========================================================
# Task 2.1: Start VM and access console (Host + Guest)
# =========================================================
sudo virsh start performance-vm
sudo virsh console performance-vm

# (Inside guest VM)
sudo modprobe virtio_balloon
echo "virtio_balloon" | sudo tee -a /etc/modules
lsmod | grep virtio_balloon
exit

# (Back on host console)
# Disconnect guest console using: ^]
# (No command here; key combo)

# =========================================================
# Task 2.1: Configure balloon device XML (Host)
# =========================================================
nano balloon_config.xml

nano setup_ballooning.sh
chmod +x setup_ballooning.sh
./setup_ballooning.sh

sudo virsh dumpxml performance-vm | grep -i balloon -n

# =========================================================
# Task 2.2: Monitor ballooning (Host)
# =========================================================
nano monitor_balloon.sh
chmod +x monitor_balloon.sh
./monitor_balloon.sh

# =========================================================
# Task 2.2: Adjust memory dynamically (Host)
# =========================================================
nano adjust_memory.sh
chmod +x adjust_memory.sh
./adjust_memory.sh
./adjust_memory.sh 2097152

# =========================================================
# Task 2.3: Auto memory balancing + cron (Host)
# =========================================================
nano auto_balance.sh
chmod +x auto_balance.sh
./auto_balance.sh
sudo virsh dommemstat performance-vm | head

(crontab -l 2>/dev/null; echo "*/5 * * * * /home/$(whoami)/auto_balance.sh") | crontab -
crontab -l

# =========================================================
# Task 3.1: Install performance tools (Host)
# =========================================================
sudo apt update
sudo apt install -y stress-ng sysbench iperf3 fio htop iotop
sudo apt install -y sysstat collectl nmon

nano install_perf_tools.sh
chmod +x install_perf_tools.sh
./install_perf_tools.sh

# =========================================================
# Task 3.2: CPU Stress Testing (Host)
# =========================================================
nano cpu_stress_test.sh
chmod +x cpu_stress_test.sh
./cpu_stress_test.sh
ls -lh /tmp/perf_logs

nano analyze_cpu_results.sh
chmod +x analyze_cpu_results.sh
./analyze_cpu_results.sh

# =========================================================
# Task 3.3: Memory Stress Testing (Host)
# =========================================================
nano memory_stress_test.sh
chmod +x memory_stress_test.sh
./memory_stress_test.sh

nano analyze_memory_results.sh
chmod +x analyze_memory_results.sh
./analyze_memory_results.sh

# =========================================================
# Task 3.4: Comprehensive Benchmark + Summary (Host)
# =========================================================
nano comprehensive_benchmark.sh
chmod +x comprehensive_benchmark.sh
./comprehensive_benchmark.sh
ls -lh /tmp/benchmark_results | tail -10

nano summarize_results.sh
chmod +x summarize_results.sh
./summarize_results.sh

# =========================================================
# Task 3.5: Quick Performance Comparison (Host)
# =========================================================
nano performance_comparison.sh
chmod +x performance_comparison.sh
./performance_comparison.sh
ls -lh /tmp/performance_comparison/optimized_results.log
tail -40 /tmp/performance_comparison/optimized_results.log

# =========================================================
# Generate performance report (Host)
# =========================================================
nano generate_report.sh
chmod +x generate_report.sh
./generate_report.sh

# =========================================================
# Troubleshooting / Verification (Host)
# =========================================================
sudo virsh domstats --balloon performance-vm | head -20
sudo virsh dumpxml performance-vm | grep balloon

sudo systemctl restart libvirtd
systemctl list-units | grep -E "libvirt|virtqemud" | head
sudo systemctl restart virtqemud.service

sudo virsh vcpuinfo performance-vm
sudo virsh capabilities | grep -A 10 topology | head -20
sudo virsh vcpupin performance-vm --vcpu 0 --cpulist 0

free -h
cat /proc/meminfo | grep -i huge
sudo virsh setmaxmem performance-vm 4194304 --config
