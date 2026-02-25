#!/bin/bash
echo "Starting CPU stress test..."
# CPU intensive task - calculate prime numbers
stress_cpu() {
 local duration=$1
 local end_time=$(($(date +%s) + duration))

 while [ $(date +%s) -lt $end_time ]; do
 # Prime number calculation
 for i in {1..10000}; do
 factor $i > /dev/null 2>&1
 done
 done
}
# Run CPU stress on multiple cores
for i in {1..2}; do
 stress_cpu 180 & # 3 minutes
done
echo "CPU stress test running for 3 minutes..."
wait
echo "CPU stress test completed."
