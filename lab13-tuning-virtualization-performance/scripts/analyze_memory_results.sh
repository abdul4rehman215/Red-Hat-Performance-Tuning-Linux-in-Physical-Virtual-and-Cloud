# scripts/analyze_memory_results.sh
#!/bin/bash
LOG_DIR="/tmp/perf_logs"

echo "=== Memory Performance Analysis ==="
echo "VM Memory - Before:"
cat $LOG_DIR/memory_before.log

echo -e "\nVM Memory - After:"
cat $LOG_DIR/memory_after.log

echo -e "\nHost Memory - Before:"
cat $LOG_DIR/host_memory_before.log

echo -e "\nHost Memory - After:"
cat $LOG_DIR/host_memory_after.log

echo -e "\nMemory Ballooning Activity (sample):"
grep -A 5 "Memory Stats:" $LOG_DIR/memory_during.log | head -20
