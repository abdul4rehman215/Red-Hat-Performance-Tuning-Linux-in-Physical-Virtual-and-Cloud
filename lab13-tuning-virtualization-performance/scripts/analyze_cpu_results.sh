# scripts/analyze_cpu_results.sh
#!/bin/bash
LOG_DIR="/tmp/perf_logs"

echo "=== CPU Performance Analysis ==="
echo "Before test:"
cat $LOG_DIR/cpu_before.log

echo -e "\nAfter test:"
cat $LOG_DIR/cpu_after.log

echo -e "\nDuring test (last 10 entries):"
tail -20 $LOG_DIR/cpu_during.log
