#!/bin/bash
# Simple memory allocation test

echo "Starting memory stress test..."

# Function to allocate memory
allocate_memory() {
  local size_mb=$1
  local duration=$2

  echo "Allocating ${size_mb}MB for ${duration} seconds..."

  # Use dd to create memory pressure
  dd if=/dev/zero of=/dev/null bs=1M count=$size_mb &
  local pid=$!

  sleep $duration
  kill $pid 2>/dev/null
  wait $pid 2>/dev/null
}

# Test different memory loads
allocate_memory 100 10
sleep 5
allocate_memory 500 15
sleep 5
allocate_memory 1000 20

echo "Memory stress test completed"
