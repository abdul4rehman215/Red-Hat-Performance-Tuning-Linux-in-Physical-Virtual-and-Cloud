# scripts/comprehensive_benchmark.sh
#!/bin/bash
VM_NAME="performance-vm"
RESULTS_DIR="/tmp/benchmark_results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p $RESULTS_DIR

echo "Starting comprehensive performance benchmark - $TIMESTAMP"

# System information
echo "=== System Information ===" > $RESULTS_DIR/system_info_$TIMESTAMP.log
lscpu >> $RESULTS_DIR/system_info_$TIMESTAMP.log
free -h >> $RESULTS_DIR/system_info_$TIMESTAMP.log
sudo virsh dominfo $VM_NAME >> $RESULTS_DIR/system_info_$TIMESTAMP.log

# CPU Benchmark
echo "Running CPU benchmark..."
sysbench cpu --cpu-max-prime=20000 --threads=4 run > $RESULTS_DIR/cpu_benchmark_$TIMESTAMP.log

# Memory Benchmark
echo "Running memory benchmark..."
sysbench memory --memory-block-size=1K --memory-scope=global --memory-total-size=2G run > $RESULTS_DIR/memory_benchmark_$TIMESTAMP.log

# File I/O Benchmark
echo "Running file I/O benchmark..."
sysbench fileio --file-total-size=2G prepare > /dev/null
sysbench fileio --file-total-size=2G --file-test-mode=rndrw --time=60 run > $RESULTS_DIR/fileio_benchmark_$TIMESTAMP.log
sysbench fileio --file-total-size=2G cleanup > /dev/null

# Combined stress test
echo "Running combined stress test..."
stress-ng --cpu 2 --vm 1 --vm-bytes 512M --io 1 --timeout 120s --metrics-brief > $RESULTS_DIR/combined_stress_$TIMESTAMP.log

echo "Comprehensive benchmark completed. Results in $RESULTS_DIR"
