#!/bin/bash
# Function to display CPU topology
show_topology() {
  echo "=== CPU Topology ==="
  lscpu | grep -E "(CPU\(s\)|Thread|Core|Socket)"
  echo ""
}

# Function to start process with specific affinity
start_with_affinity() {
  local script=$1
  local cores=$2
  local duration=$3

  echo "Starting $script on cores $cores for ${duration}s"
  taskset -c $cores python3 $script $duration &
  local pid=$!
  echo "PID: $pid, Affinity: $cores"
  return $pid
}

# Function to monitor process affinity
monitor_affinity() {
  local pid=$1
  echo "Process $pid affinity: $(taskset -p $pid 2>/dev/null | cut -d: -f2)"
}

show_topology

# Get number of CPUs
NCPUS=$(nproc)
echo "Available CPUs: $NCPUS"

if [ $NCPUS -ge 4 ]; then
  echo "Optimal configuration for 4+ cores"
  CORE_SET1="0,1"
  CORE_SET2="2,3"
  CORE_SET3="0-3"
else
  echo "Configuration for fewer cores"
  CORE_SET1="0"
  CORE_SET2="1"
  CORE_SET3="0,1"
fi

echo "Core assignments:"
echo " CPU-intensive task 1: $CORE_SET1"
echo " CPU-intensive task 2: $CORE_SET2"
echo " Memory-intensive task: $CORE_SET3"
echo ""
