# scripts/install_perf_tools.sh
#!/bin/bash
echo "Installing performance testing tools..."

# System stress testing
sudo apt install -y stress-ng

# Database/CPU benchmarking
sudo apt install -y sysbench

# Network performance testing
sudo apt install -y iperf3 netperf

# Disk I/O testing
sudo apt install -y fio

# System monitoring
sudo apt install -y htop iotop sysstat collectl

# Memory testing
sudo apt install -y memtester

echo "Performance tools installation completed"
