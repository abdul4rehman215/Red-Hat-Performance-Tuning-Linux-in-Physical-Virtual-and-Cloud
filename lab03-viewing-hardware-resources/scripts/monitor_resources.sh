#!/bin/bash
echo "Monitoring system resources for 60 seconds..."
echo "Timestamp,CPU_Usage,Memory_Usage,Disk_Usage" > resource_log.csv

for i in {1..12}; do
 timestamp=$(date '+%Y-%m-%d %H:%M:%S')
 cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
 memory_usage=$(free | awk 'NR==2{printf "%.1f", $3*100/$2}')
 disk_usage=$(df / | awk 'NR==2{print $5}' | cut -d'%' -f1)

 echo "$timestamp,$cpu_usage,$memory_usage,$disk_usage" >> resource_log.csv
 sleep 5
done

echo "Resource monitoring complete. Check resource_log.csv for results."
