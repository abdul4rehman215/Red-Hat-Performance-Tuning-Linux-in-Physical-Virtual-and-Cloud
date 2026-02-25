# scripts/summarize_results.sh
#!/bin/bash
RESULTS_DIR="/tmp/benchmark_results"
LATEST_SYSTEM=$(ls -1t $RESULTS_DIR/system_info_* 2>/dev/null | head -1)

if [ -z "$LATEST_SYSTEM" ]; then
  echo "No benchmark results found in $RESULTS_DIR"
  exit 1
fi

LATEST_TIMESTAMP=$(basename "$LATEST_SYSTEM" | sed 's/system_info_//' | sed 's/\.log//')

echo "=== Performance Benchmark Summary ==="
echo "Timestamp: $LATEST_TIMESTAMP"
echo

echo "System Configuration:"
cat $RESULTS_DIR/system_info_$LATEST_TIMESTAMP.log
echo

echo "CPU Performance:"
grep -E "(events per second|total time)" $RESULTS_DIR/cpu_benchmark_$LATEST_TIMESTAMP.log
echo

echo "Memory Performance:"
grep -E "(transferred|total time)" $RESULTS_DIR/memory_benchmark_$LATEST_TIMESTAMP.log
echo

echo "File I/O Performance:"
grep -E "(read|written|total time)" $RESULTS_DIR/fileio_benchmark_$LATEST_TIMESTAMP.log
echo

echo "Combined Stress Test Results:"
grep -E "(successful run|successful runs|failed run|failed runs)" $RESULTS_DIR/combined_stress_$LATEST_TIMESTAMP.log
