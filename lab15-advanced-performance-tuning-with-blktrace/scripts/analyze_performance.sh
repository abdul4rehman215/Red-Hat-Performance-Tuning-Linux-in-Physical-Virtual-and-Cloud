# scripts/analyze_performance.sh
#!/bin/bash
TRACE_FILE="parsed_trace.txt"

if [ ! -f "$TRACE_FILE" ]; then
  echo "Error: Trace file $TRACE_FILE not found!"
  exit 1
fi

echo "=== DETAILED PERFORMANCE ANALYSIS ==="
echo "Analysis of: $TRACE_FILE"
echo "Generated on: $(date)"
echo

# Calculate basic metrics
TOTAL_OPS=$(wc -l < $TRACE_FILE)
READ_OPS=$(grep -c " R " $TRACE_FILE)
WRITE_OPS=$(grep -c " W " $TRACE_FILE)

echo "=== OPERATION STATISTICS ==="
echo "Total operations: $TOTAL_OPS"
echo "Read operations: $READ_OPS ($(( READ_OPS * 100 / TOTAL_OPS ))%)"
echo "Write operations: $WRITE_OPS ($(( WRITE_OPS * 100 / TOTAL_OPS ))%)"
echo

# Analyze I/O sizes
echo "=== I/O SIZE ANALYSIS ==="
awk '/[RW]/ {
  size = $10
  if (size <= 4096) small++
  else if (size <= 65536) medium++
  else large++
  total++
}
END {
  print "Small I/O (<=4KB): " small " (" int(small*100/total) "%)"
  print "Medium I/O (4KB-64KB): " medium " (" int(medium*100/total) "%)"
  print "Large I/O (>64KB): " large " (" int(large*100/total) "%)"
}' $TRACE_FILE
echo

# Analyze sequential vs random patterns
echo "=== ACCESS PATTERN ANALYSIS ==="
awk '/[RW]/ {
  sector = $8
  if (prev_sector != "" && sector == prev_sector + prev_size/512) {
    sequential++
  } else {
    random++
  }
  prev_sector = sector
  prev_size = $10
  total++
}
END {
  if (total > 0) {
    print "Sequential I/O: " sequential " (" int(sequential*100/total) "%)"
    print "Random I/O: " random " (" int(random*100/total) "%)"
  }
}' $TRACE_FILE
echo

# Calculate average latency (simplified)
echo "=== LATENCY ANALYSIS ==="
awk '
/Q/ { queue_time[$6] = $4 }
/C/ {
  if (queue_time[$6] != "") {
    latency = $4 - queue_time[$6]
    if (latency > 0) {
      total_latency += latency
      count++
    }
  }
}
END {
  if (count > 0) {
    avg_latency = total_latency / count
    print "Average I/O latency: " avg_latency " seconds"
    print "Operations with latency data: " count
  }
}' $TRACE_FILE
