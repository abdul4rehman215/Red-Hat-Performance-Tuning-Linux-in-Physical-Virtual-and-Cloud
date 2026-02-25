#!/bin/bash
# Node + pod aggregation monitoring (CSV) for 5 minutes

NAMESPACE="performance-lab"
DURATION=300
INTERVAL=10
OUT_FILE="performance_report.csv"

echo "Starting performance monitoring for $DURATION seconds..."
echo "Timestamp,Node_CPU,Node_Memory,Pod_Count,Avg_Pod_CPU,Avg_Pod_Memory" > "$OUT_FILE"

start_time=$(date +%s)
end_time=$((start_time + DURATION))

while [ "$(date +%s)" -lt "$end_time" ]; do
  ts=$(date '+%Y-%m-%d %H:%M:%S')

  # node CPU + memory (first node only; single-node cluster)
  node_metrics=$(kubectl top nodes --no-headers 2>/dev/null | head -1 | awk '{print $2","$4}')

  # pod count
  pod_count=$(kubectl get pods -n "$NAMESPACE" --no-headers 2>/dev/null | wc -l)

  # average pod metrics (CPU/mem columns like: 35m 48Mi)
  pod_metrics=$(kubectl top pods -n "$NAMESPACE" --no-headers 2>/dev/null \
    | awk '{cpu+=$2; mem+=$3; c++} END {if(c>0) printf "%dm,%dMi\n", cpu/c, mem/c; else print "0m,0Mi"}')

  echo "$ts,$node_metrics,$pod_count,$pod_metrics" >> "$OUT_FILE"
  sleep "$INTERVAL"
done

echo "Performance monitoring completed. Report saved to $OUT_FILE"
