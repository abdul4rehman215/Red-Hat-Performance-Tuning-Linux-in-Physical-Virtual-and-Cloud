#!/bin/bash
# Network performance watchdog script
LOG_FILE="/var/log/network_performance.log"
while true; do
  timestamp=$(date)

  # Collect metrics
  established=$(ss -tan state established | wc -l)
  time_wait=$(ss -tan state time-wait | wc -l)
  tcp_mem=$(cat /proc/net/sockstat | grep TCP | awk '{print $3}')

  # Log metrics
  echo "$timestamp - EST:$established TW:$time_wait MEM:$tcp_mem" >> $LOG_FILE

  # Alert conditions
  if [ $established -gt 2000 ]; then
    echo "$timestamp - ALERT: High connection count ($established)" >> $LOG_FILE
  fi

  if [ $time_wait -gt 1000 ]; then
    echo "$timestamp - ALERT: High TIME_WAIT count ($time_wait)" >> $LOG_FILE
  fi

  sleep 60
done
