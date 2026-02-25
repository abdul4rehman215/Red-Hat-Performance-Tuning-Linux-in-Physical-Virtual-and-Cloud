#!/bin/bash
# Logs docker stats into CSV (10 samples, every 10s)

OUT_FILE="docker_performance.csv"
echo "Timestamp,Container,CPU%,MemUsage,Mem%,NetIO,BlockIO" > "$OUT_FILE"

for i in {1..10}; do
  ts=$(date '+%Y-%m-%d %H:%M:%S')
  docker stats --no-stream --format "{{.Container}},{{.CPUPerc}},{{.MemUsage}},{{.MemPerc}},{{.NetIO}},{{.BlockIO}}" \
    | while read -r line; do
        echo "$ts,$line" >> "$OUT_FILE"
      done
  sleep 10
done
