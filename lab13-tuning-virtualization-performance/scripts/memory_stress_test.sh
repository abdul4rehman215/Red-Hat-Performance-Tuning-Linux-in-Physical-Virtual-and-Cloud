# scripts/memory_stress_test.sh
#!/bin/bash
VM_NAME="performance-vm"
TEST_DURATION=300
LOG_DIR="/tmp/perf_logs"

mkdir -p $LOG_DIR

echo "Starting memory performance test for $VM_NAME"

# Baseline memory stats
sudo virsh dommemstat $VM_NAME > $LOG_DIR/memory_before.log
free -h > $LOG_DIR/host_memory_before.log

# Memory stress test with monitoring
echo "Running memory stress test..."
stress-ng --vm 2 --vm-bytes 1G --timeout ${TEST_DURATION}s --metrics-brief &
STRESS_PID=$!

# Monitor memory ballooning during test
while kill -0 $STRESS_PID 2>/dev/null; do
 echo "$(date): Memory Stats:" >> $LOG_DIR/memory_during.log
 sudo virsh dommemstat $VM_NAME >> $LOG_DIR/memory_during.log
 free -h >> $LOG_DIR/memory_during.log
 echo "---" >> $LOG_DIR/memory_during.log
 sleep 15
done

# Final memory stats
sudo virsh dommemstat $VM_NAME > $LOG_DIR/memory_after.log
free -h > $LOG_DIR/host_memory_after.log

echo "Memory stress test completed"
