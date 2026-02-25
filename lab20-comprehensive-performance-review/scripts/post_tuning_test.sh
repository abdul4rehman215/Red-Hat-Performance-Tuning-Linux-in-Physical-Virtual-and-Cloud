#!/bin/bash
echo "POST-TUNING PERFORMANCE TEST"
echo "============================"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
TEST_DIR="/opt/performance-review/post_tuning_${TIMESTAMP}"
mkdir -p "$TEST_DIR"
echo "Test directory: $TEST_DIR"
echo "Starting performance test..."

# Quick system snapshot
echo "System snapshot at $(date):" > "$TEST_DIR/system_snapshot.txt"
echo "Load average: $(uptime | awk -F'load average:' '{print $2}')" >> "$TEST_DIR/system_snapshot.txt"
echo "Memory usage: $(free -h | grep Mem)" >> "$TEST_DIR/system_snapshot.txt"
echo "CPU usage: $(top -bn1 | grep "Cpu(s)")" >> "$TEST_DIR/system_snapshot.txt"

# CPU performance test
echo "Running CPU performance test..."
time_output=$(time (for i in {1..5000}; do factor $i >/dev/null 2>&1; done) 2>&1)
echo "CPU test result: $time_output" > "$TEST_DIR/cpu_test.txt"

# Memory performance test
echo "Running memory performance test..."
dd if=/dev/zero of="$TEST_DIR/memory_test.tmp" bs=1M count=100 2>&1 | \
grep -E "(copied|MB/s)" > "$TEST_DIR/memory_test.txt"
rm -f "$TEST_DIR/memory_test.tmp"

# Disk I/O performance test
echo "Running disk I/O performance test..."
sync
echo 3 > /proc/sys/vm/drop_caches 2>/dev/null || true

# Write test
write_result=$(dd if=/dev/zero of="$TEST_DIR/io_test.tmp" bs=1M count=50 2>&1 | \
grep -E "(copied|MB/s|GB/s)")
echo "Write test: $write_result" > "$TEST_DIR/io_test.txt"

# Read test
sync
read_result=$(dd if="$TEST_DIR/io_test.tmp" of=/dev/null bs=1M 2>&1 | \
grep -E "(copied|MB/s|GB/s)")
echo "Read test: $read_result" >> "$TEST_DIR/io_test.txt"
rm -f "$TEST_DIR/io_test.tmp"

# Network performance test (loopback)
echo "Running network performance test..."
timeout 10 iperf3 -s >/dev/null 2>&1 &
sleep 2
iperf3 -c localhost -t 5 2>/dev/null | grep "sender\|receiver" > "$TEST_DIR/network_test.txt" || \
echo "Network test skipped - iperf3 not available" > "$TEST_DIR/network_test.txt"

echo "Performance test completed. Results saved in: $TEST_DIR"

# Display summary
echo ""
echo "PERFORMANCE TEST SUMMARY:"
echo "========================"
cat "$TEST_DIR/system_snapshot.txt"
echo ""
echo "CPU Test:"
cat "$TEST_DIR/cpu_test.txt"
echo ""
echo "Memory Test:"
cat "$TEST_DIR/memory_test.txt"
echo ""
echo "I/O Test:"
cat "$TEST_DIR/io_test.txt"
echo ""
echo "Network Test:"
cat "$TEST_DIR/network_test.txt"
