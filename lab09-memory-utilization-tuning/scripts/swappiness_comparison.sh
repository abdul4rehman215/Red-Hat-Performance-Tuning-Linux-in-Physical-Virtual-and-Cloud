#!/bin/bash
RESULTS_DIR="swappiness_results_$(date +%Y%m%d_%H%M%S)"
mkdir -p $RESULTS_DIR

echo "Swappiness Comparison Test"
echo "========================="
echo "Results directory: $RESULTS_DIR"

# Function to test specific swappiness value
test_swappiness() {
  local swappiness_value=$1
  local test_duration=60

  echo "Testing swappiness = $swappiness_value"

  # Set swappiness value
  sudo sysctl vm.swappiness=$swappiness_value

  # Clear caches to ensure consistent starting point
  sudo sync
  echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null

  # Wait for system to stabilize
  sleep 5

  # Start monitoring
  local log_file="$RESULTS_DIR/swappiness_${swappiness_value}.log"

  {
    echo "=== Swappiness $swappiness_value Test ==="
    echo "Start time: $(date)"
    echo "Initial state:"
    free -h
    echo ""
  } > $log_file

  # Start background monitoring
  vmstat 2 30 >> $log_file &
  local vmstat_pid=$!

  # Create memory pressure
  if command -v stress-ng >/dev/null 2>&1; then
    stress-ng --vm 1 --vm-bytes 80% --timeout ${test_duration}s
  else
    dd if=/dev/zero of=/tmp/test_file bs=1M count=1024 2>/dev/null
    rm -f /tmp/test_file
  fi

  # Stop monitoring
  kill $vmstat_pid 2>/dev/null
  wait $vmstat_pid 2>/dev/null

  # Log final state
  {
    echo ""
    echo "Final state:"
    free -h
    echo "End time: $(date)"
  } >> $log_file

  echo "Completed test for swappiness = $swappiness_value"
  sleep 10
}

# Test different swappiness values
for swappiness in 1 10 30 60 100; do
  test_swappiness $swappiness
done

# Generate summary report
echo "Generating summary report..."
cat << 'REPORT_EOF' > $RESULTS_DIR/summary_report.sh
#!/bin/bash
echo "=== Swappiness Comparison Summary ==="
echo "Generated: $(date)"
echo ""
for file in swappiness_*.log; do
  if [ -f "$file" ]; then
    swappiness_val=$(echo $file | grep -o '[0-9]\+')
    echo "Swappiness $swappiness_val:"
    echo " Swap in/out activity:"
    grep -E "(si|so)" $file | tail -5 | awk '{print " si: " $7 ", so: " $8}'
    echo ""
  fi
done
REPORT_EOF

chmod +x $RESULTS_DIR/summary_report.sh
cd $RESULTS_DIR && ./summary_report.sh
cd ..

echo "Swappiness comparison complete!"
echo "Check results in: $RESULTS_DIR"
