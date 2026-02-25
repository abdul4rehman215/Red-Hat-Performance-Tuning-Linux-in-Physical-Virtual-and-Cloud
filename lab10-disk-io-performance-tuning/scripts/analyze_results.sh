#!/bin/bash
echo "=== I/O Scheduler Performance Analysis ==="
echo

DEVICE="nvme0n1"

# Function to get current scheduler
get_current_scheduler() {
  cat /sys/block/$DEVICE/queue/scheduler | grep -o '\[.*\]' | tr -d '[]'
}

# Test different workload scenarios
test_workload() {
  local workload_name=$1
  local fio_params=$2

  echo "Testing workload: $workload_name"
  echo "Current scheduler: $(get_current_scheduler)"

  mkdir -p /tmp/iotest

  # Run iostat in background
  iostat -x 1 10 > /tmp/iostat_${workload_name}.log &
  iostat_pid=$!

  # Run fio test
  fio $fio_params --filename=/tmp/iotest/workload_test > /tmp/fio_${workload_name}.log 2>&1

  # Stop iostat
  kill $iostat_pid 2>/dev/null

  # Extract key metrics (best-effort parsing)
  iops=$(grep "IOPS=" /tmp/fio_${workload_name}.log | head -1 | sed -n 's/.*IOPS=\([0-9.]*[kKmM]*\).*/\1/p')
  bandwidth=$(grep "BW=" /tmp/fio_${workload_name}.log | head -1 | sed -n 's/.*BW=\([0-9.]*[KMG]iB\/s\).*/\1/p')
  latency=$(grep -i " lat " /tmp/fio_${workload_name}.log | grep "avg" | head -1 | awk '{print $NF}')

  echo " IOPS: $iops"
  echo " Bandwidth: $bandwidth"
  echo " Average Latency: $latency"
  echo
}

# Database-like workload (random read/write)
echo "=== Database Workload Test ==="
test_workload "database" "--name=db-test --ioengine=libaio --iodepth=8 --rw=randrw --rwmixread=70 --bs=8k --direct=1 --size=500M --numjobs=2 --runtime=10 --time_based --group_reporting"

# Web server workload (mostly reads)
echo "=== Web Server Workload Test ==="
test_workload "webserver" "--name=web-test --ioengine=libaio --iodepth=4 --rw=randrw --rwmixread=90 --bs=4k --direct=1 --size=500M --numjobs=4 --runtime=10 --time_based --group_reporting"

# File server workload (sequential-ish)
echo "=== File Server Workload Test ==="
test_workload "fileserver" "--name=file-test --ioengine=libaio --iodepth=2 --rw=rw --rwmixread=60 --bs=64k --direct=1 --size=500M --numjobs=1 --runtime=10 --time_based --group_reporting"

echo "=== Analysis Complete ==="
echo "Check log files in /tmp/ for detailed results"
