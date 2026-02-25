#!/bin/bash
# Disk Performance Testing Script
DEVICE="nvme0n1" # Change this to your disk device
TEST_FILE="/tmp/iotest/perftest"
TEST_SIZE="1G"
SCHEDULERS=("mq-deadline" "kyber" "bfq" "none")

# Create test directory
mkdir -p /tmp/iotest

echo "=== Disk Performance Testing ==="
echo "Device: /dev/$DEVICE"
echo "Test file: $TEST_FILE"
echo "Test size: $TEST_SIZE"
echo

# Function to test scheduler performance
test_scheduler() {
  local scheduler=$1
  echo "Testing scheduler: $scheduler"

  # Set scheduler
  echo $scheduler | sudo tee /sys/block/$DEVICE/queue/scheduler > /dev/null

  # Clear cache
  sync
  echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null

  # Sequential write test
  echo " Sequential write test..."
  write_result=$(dd if=/dev/zero of=$TEST_FILE bs=1M count=1024 oflag=direct 2>&1 | tail -1 | awk '{print $(NF-1),$NF}')

  # Sequential read test
  echo " Sequential read test..."
  read_result=$(dd if=$TEST_FILE of=/dev/null bs=1M iflag=direct 2>&1 | tail -1 | awk '{print $(NF-1),$NF}')

  # Random I/O test using fio (if available)
  fio_result=""
  if command -v fio &> /dev/null; then
    echo " Random I/O test..."
    fio_result=$(fio --name=random-rw --ioengine=libaio --iodepth=4 --rw=randrw --bs=4k --direct=1 \
      --size=100M --numjobs=1 --filename=$TEST_FILE --group_reporting --runtime=10 --time_based 2>/dev/null | \
      grep -E "read:|write:" | head -2)
  fi

  echo " Results for $scheduler:"
  echo " Sequential Write: $write_result"
  echo " Sequential Read:  $read_result"
  if [ ! -z "$fio_result" ]; then
    echo " Random I/O: $fio_result"
  fi
  echo

  # Clean up
  rm -f $TEST_FILE
}

# Test each scheduler
for scheduler in "${SCHEDULERS[@]}"; do
  # Check if scheduler is available
  if grep -q $scheduler /sys/block/$DEVICE/queue/scheduler; then
    test_scheduler $scheduler
  else
    echo "Scheduler $scheduler not available on this system"
  fi
done

echo "=== Testing Complete ==="
