#!/bin/bash
echo "=== System Scalability Testing ==="
echo ""

# Function to test CPU scalability
test_cpu_scalability() {
 echo "Testing CPU scalability..."

 for load_level in 1 2 4; do
  echo " Testing with $load_level concurrent processes..."

  # Start background processes
  for i in $(seq 1 $load_level); do
   (for j in {1..1000}; do echo "scale=100; sqrt($j)" | bc -l > /dev/null; done) &
  done

  # Measure time for completion
  start_time=$(date +%s)
  wait
  end_time=$(date +%s)

  duration=$((end_time - start_time))
  echo " Load level $load_level completed in ${duration}s"
 done
 echo ""
}

# Function to test memory scalability
test_memory_scalability() {
 echo "Testing memory allocation scalability..."

 for mem_size in 10 50 100; do
  echo " Testing ${mem_size}MB allocation..."
  start_time=$(date +%s.%N)

  # Allocate memory using dd
  dd if=/dev/zero of=/tmp/mem_test bs=1M count=$mem_size 2>/dev/null

  end_time=$(date +%s.%N)
  duration=$(echo "$end_time - $start_time" | bc)

  echo " ${mem_size}MB allocation took ${duration}s"
  rm -f /tmp/mem_test
 done
 echo ""
}

# Function to test I/O scalability
test_io_scalability() {
 echo "Testing I/O scalability..."

 for file_count in 1 5 10; do
  echo " Testing with $file_count concurrent file operations..."
  start_time=$(date +%s)

  for i in $(seq 1 $file_count); do
   (dd if=/dev/zero of=/tmp/io_test_$i bs=1M count=10 2>/dev/null; rm -f /tmp/io_test_$i) &
  done

  wait
  end_time=$(date +%s)
  duration=$((end_time - start_time))

  echo " $file_count concurrent operations completed in ${duration}s"
 done
 echo ""
}

# Run scalability tests
test_cpu_scalability
test_memory_scalability
test_io_scalability

echo "=== Scalability Testing Complete ==="
