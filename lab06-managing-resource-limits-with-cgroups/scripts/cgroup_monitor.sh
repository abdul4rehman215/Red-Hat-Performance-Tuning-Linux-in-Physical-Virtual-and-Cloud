#!/bin/bash
CGROUP_PATH="/sys/fs/cgroup/lab6_demo"
echo "=== cgroup Resource Monitor ==="
echo "Monitoring cgroup: $CGROUP_PATH"
echo "Press Ctrl+C to stop"
echo
while true; do
 clear
 echo "=== cgroup Resource Monitor - $(date) ==="
 echo

 # CPU Statistics
 echo "CPU Statistics:"
 if [ -f "$CGROUP_PATH/cpu.stat" ]; then
  cat "$CGROUP_PATH/cpu.stat" | while read line; do
   echo " $line"
  done
 fi
 echo

 # Memory Statistics
 echo "Memory Usage:"
 if [ -f "$CGROUP_PATH/memory.current" ]; then
  current=$(cat "$CGROUP_PATH/memory.current")
  max=$(cat "$CGROUP_PATH/memory.max")
  echo " Current: $(($current / 1024 / 1024)) MB"
  echo " Limit: $(($max / 1024 / 1024)) MB"
  echo " Usage: $((current * 100 / max))%"
 fi
 echo

 # I/O Statistics
 echo "I/O Statistics:"
 if [ -f "$CGROUP_PATH/io.stat" ]; then
  cat "$CGROUP_PATH/io.stat" | while read line; do
   echo " $line"
  done
 fi
 echo

 # Process Count
 echo "Processes in cgroup:"
 if [ -f "$CGROUP_PATH/cgroup.procs" ]; then
  proc_count=$(cat "$CGROUP_PATH/cgroup.procs" | wc -l)
  echo " Count: $proc_count"
  if [ $proc_count -gt 0 ]; then
   echo " PIDs: $(cat "$CGROUP_PATH/cgroup.procs" | tr '\n' ' ')"
  fi
 fi

 sleep 2
done
