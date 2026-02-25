#!/bin/bash
echo "=== System Call Performance Analysis ==="

# Function to analyze strace output
analyze_trace() {
  local trace_file=$1
  echo "Analyzing: $trace_file"
  echo "----------------------------------------"

  # Count system calls
  echo "Top 10 most frequent system calls:"
  grep -E "^[0-9]+" "$trace_file" | awk '{print $2}' | cut -d'(' -f1 | sort | uniq -c | sort -nr | head -10

  echo ""
  echo "File operations count:"
  grep -E "(open|read|write|close)" "$trace_file" | wc -l

  echo ""
  echo "Potential issues:"

  # Check for excessive file operations (note: this checks open( specifically)
  open_count=$(grep -c "open(" "$trace_file")
  if [ "$open_count" -gt 100 ]; then
    echo "- WARNING: High number of open() calls ($open_count)"
  fi

  # Check for failed system calls
  failed_calls=$(grep -c "= -1" "$trace_file")
  if [ "$failed_calls" -gt 0 ]; then
    echo "- WARNING: $failed_calls failed system calls detected"
  fi

  echo "----------------------------------------"
}

# Run performance test and analyze
echo "Running performance test with strace..."
strace -c -o perf_summary.txt ./performance_test

echo ""
echo "System call summary:"
cat perf_summary.txt

# Create detailed trace
strace -o detailed_perf.txt ./performance_test

# Analyze the trace
analyze_trace detailed_perf.txt
