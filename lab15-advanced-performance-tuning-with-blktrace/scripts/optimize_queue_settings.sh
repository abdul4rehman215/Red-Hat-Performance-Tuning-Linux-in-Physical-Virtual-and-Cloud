# scripts/optimize_queue_settings.sh
#!/bin/bash
DEVICE=${1:-sda}

echo "=== OPTIMIZING QUEUE SETTINGS FOR $DEVICE ==="

# Current settings
echo "Current queue depth: $(cat /sys/block/$DEVICE/queue/nr_requests)"
echo "Current read-ahead: $(cat /sys/block/$DEVICE/queue/read_ahead_kb)KB"

# Test different queue depths
echo -e "\n--- Testing Queue Depth Settings ---"
for queue_depth in 32 64 128 256; do
  echo "Testing queue depth: $queue_depth"
  echo $queue_depth | sudo tee /sys/block/$DEVICE/queue/nr_requests

  # Performance test
  time_result=$(sudo dd if=/opt/blktrace-lab/test_100mb.dat of=/dev/null bs=64k 2>&1 | grep -E "copied.*s")
  echo "Result: $time_result"

  sleep 1
done

echo -e "\n--- Testing Read-Ahead Settings ---"
# Test different read-ahead values
for read_ahead in 128 256 512 1024 2048; do
  echo "Testing read-ahead: ${read_ahead}KB"
  echo $read_ahead | sudo tee /sys/block/$DEVICE/queue/read_ahead_kb

  # Sequential read test
  time_result=$(sudo dd if=/opt/blktrace-lab/test_100mb.dat of=/dev/null bs=4k 2>&1 | grep -E "copied.*s")
  echo "Result: $time_result"

  sleep 1
done

# Set optimal values based on typical workloads
echo -e "\n--- Applying Optimized Settings ---"
# For general purpose workloads
echo 128 | sudo tee /sys/block/$DEVICE/queue/nr_requests
echo 512 | sudo tee /sys/block/$DEVICE/queue/read_ahead_kb

# Additional optimizations
echo "Applying additional optimizations..."

# Set optimal rotational setting
if [ -f /sys/block/$DEVICE/queue/rotational ]; then
  rotational=$(cat /sys/block/$DEVICE/queue/rotational)
  echo "Current rotational setting: $rotational"
fi

echo "Queue optimization completed."
echo "Final settings:"
echo "Queue depth: $(cat /sys/block/$DEVICE/queue/nr_requests)"
echo "Read-ahead: $(cat /sys/block/$DEVICE/queue/read_ahead_kb)KB"
