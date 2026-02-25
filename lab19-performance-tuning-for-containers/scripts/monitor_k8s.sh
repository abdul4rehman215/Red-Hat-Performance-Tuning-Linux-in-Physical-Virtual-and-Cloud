#!/bin/bash
# Logs kubectl top pods into CSV (10 samples, every 30s)

NAMESPACE="performance-lab"
OUT_FILE="k8s_performance.csv"

echo "Timestamp,Pod,CPU,Memory" > "$OUT_FILE"

for i in {1..10}; do
  ts=$(date '+%Y-%m-%d %H:%M:%S')
  kubectl top pods -n "$NAMESPACE" --no-headers 2>/dev/null | while read -r line; do
    echo "$ts,$line" >> "$OUT_FILE"
  done
  sleep 30
done
