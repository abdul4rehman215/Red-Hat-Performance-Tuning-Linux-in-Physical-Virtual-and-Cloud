commands.sh
#!/bin/bash
# Lab 15 - Advanced Performance Tuning with Blktrace
# Commands Executed During Lab (Ubuntu 24.04.1)

# ============================================
# Task 1.1: Install Blktrace Package + Tools
# ============================================
sudo apt update
sudo apt install -y blktrace
sudo apt install -y sysstat iotop

# ============================================
# Task 1.2: Verify Installation + Devices
# ============================================
blktrace -V
lsblk

for dev in $(lsblk -d -o NAME --noheadings); do
  if [ -f /sys/block/$dev/queue/scheduler ]; then
    echo "Device $dev scheduler: $(cat /sys/block/$dev/queue/scheduler)"
  fi
done

iostat -x 1 3

# ============================================
# Task 1.3: Prepare Test Environment
# ============================================
sudo mkdir -p /opt/blktrace-lab
cd /opt/blktrace-lab

sudo dd if=/dev/zero of=test_1mb.dat bs=1M count=1
sudo dd if=/dev/zero of=test_10mb.dat bs=1M count=10
sudo dd if=/dev/zero of=test_100mb.dat bs=1M count=100

sudo nano io_load_generator.sh
sudo chmod +x io_load_generator.sh

# ============================================
# Task 2.1: Basic Blktrace Usage
# ============================================
PRIMARY_DEVICE=$(lsblk -d -o NAME --noheadings | head -1)
echo "Primary device: $PRIMARY_DEVICE"

# Fix: select first real disk (TYPE=disk), not loop
PRIMARY_DEVICE=$(lsblk -d -o NAME,TYPE --noheadings | awk '$2=="disk"{print $1; exit}')
echo "Primary device: $PRIMARY_DEVICE"

sudo blktrace -d /dev/$PRIMARY_DEVICE -o trace_basic &
TRACE_PID=$!

sudo dd if=/dev/zero of=/opt/blktrace-lab/trace_test.dat bs=1M count=50
sleep 2
sudo kill $TRACE_PID
wait $TRACE_PID 2>/dev/null

ls -la trace_basic.*

# ============================================
# Task 2.2: Advanced Trace Script
# ============================================
sudo nano advanced_trace.sh
sudo chmod +x advanced_trace.sh

# ============================================
# Task 2.3: Concurrent Tracing + I/O Load
# ============================================
sudo ./advanced_trace.sh $PRIMARY_DEVICE 45 &
TRACE_SCRIPT_PID=$!

sleep 3

echo "Generating I/O load..."
sudo ./io_load_generator.sh 30

echo "Testing sequential read pattern..."
sudo dd if=/opt/blktrace-lab/test_100mb.dat of=/dev/null bs=64k

echo "Testing random write pattern..."
sudo dd if=/dev/urandom of=/opt/blktrace-lab/random_test.dat bs=4k count=1000

wait $TRACE_SCRIPT_PID

echo "Trace and I/O generation completed."

# ============================================
# Task 2.4: Parse and Analyze Trace Data
# ============================================
sudo blkparse -i advanced_trace -o parsed_trace.txt

# Fix for realistic summation: use bytes (ls -l)
ls -l advanced_trace.* | awk '{sum+=$5} END {printf "%.2f MB\n", sum/1024/1024}'

head -20 parsed_trace.txt

grep -c " Q " parsed_trace.txt | xargs echo "Queue operations:"
grep -c " I " parsed_trace.txt | xargs echo "Issue operations:"
grep -c " C " parsed_trace.txt | xargs echo "Complete operations:"

grep -c " R " parsed_trace.txt | xargs echo "Read operations:"
grep -c " W " parsed_trace.txt | xargs echo "Write operations:"

# ============================================
# Task 3.1: Detailed Analysis Script
# ============================================
sudo nano analyze_performance.sh
sudo chmod +x analyze_performance.sh
sudo ./analyze_performance.sh

# ============================================
# Task 3.2: Baseline Scheduler + Queue + Read-ahead + Performance Baseline
# ============================================
echo "=== CURRENT I/O SCHEDULER CONFIGURATION ==="
for dev in $(lsblk -d -o NAME --noheadings); do
  if [ -f /sys/block/$dev/queue/scheduler ]; then
    current=$(cat /sys/block/$dev/queue/scheduler)
    echo "Device /dev/$dev: $current"
  fi
done

echo -e "\n=== CURRENT QUEUE DEPTH SETTINGS ==="
for dev in $(lsblk -d -o NAME --noheadings); do
  if [ -f /sys/block/$dev/queue/nr_requests ]; then
    nr_requests=$(cat /sys/block/$dev/queue/nr_requests)
    echo "Device /dev/$dev queue depth: $nr_requests"
  fi
done

echo -e "\n=== CURRENT READ-AHEAD SETTINGS ==="
for dev in $(lsblk -d -o NAME --noheadings); do
  if [ -f /sys/block/$dev/queue/read_ahead_kb ]; then
    read_ahead=$(cat /sys/block/$dev/queue/read_ahead_kb)
    echo "Device /dev/$dev read-ahead: ${read_ahead}KB"
  fi
done

echo -e "\n=== BASELINE PERFORMANCE TEST ==="
echo "Sequential read test (64KB blocks):"
sudo dd if=/opt/blktrace-lab/test_100mb.dat of=/dev/null bs=64k 2>&1 | grep -E "(copied|MB/s|GB/s)"

echo "Sequential write test (64KB blocks):"
sudo dd if=/dev/zero of=/opt/blktrace-lab/baseline_write.dat bs=64k count=1000 2>&1 | grep -E "(copied|MB/s|GB/s)"
sudo rm -f /opt/blktrace-lab/baseline_write.dat

if command -v fio >/dev/null 2>&1; then
  echo "Random read test (4KB blocks):"
  sudo fio --name=random_read --ioengine=libaio --rw=randread --bs=4k --numjobs=1 --size=50m --runtime=10 --directory=/opt/blktrace-lab --group_reporting
else
  echo "Random read test (using dd with random seeks):"
  time (for i in {1..100}; do
    sudo dd if=/opt/blktrace-lab/test_100mb.dat of=/dev/null bs=4k count=1 skip=$((RANDOM % 1000)) 2>/dev/null
  done)
fi

# ============================================
# Task 3.3: Scheduler Tuning Script + Tests
# ============================================
sudo nano tune_io_scheduler.sh
sudo chmod +x tune_io_scheduler.sh

echo "=== TESTING DIFFERENT I/O SCHEDULERS ==="
AVAILABLE_SCHEDULERS=$(cat /sys/block/$PRIMARY_DEVICE/queue/scheduler | tr '[]' ' ' | tr ' ' '\n' | grep -v '^$')
echo "Available schedulers for $PRIMARY_DEVICE:"
echo "$AVAILABLE_SCHEDULERS"

# --- Scheduler: none ---
sudo ./tune_io_scheduler.sh $PRIMARY_DEVICE none
sleep 2
sudo dd if=/opt/blktrace-lab/test_100mb.dat of=/dev/null bs=64k 2>&1 | grep -E "(copied|MB/s|GB/s)"
sudo blktrace -d /dev/$PRIMARY_DEVICE -o trace_none &
TRACE_PID=$!
sudo dd if=/dev/zero of=/opt/blktrace-lab/scheduler_test.dat bs=64k count=500 2>/dev/null
sleep 2
sudo kill $TRACE_PID 2>/dev/null
wait $TRACE_PID 2>/dev/null
sudo blkparse -i trace_none -o parsed_none.txt 2>/dev/null
[ -f parsed_none.txt ] && wc -l parsed_none.txt
sudo rm -f /opt/blktrace-lab/scheduler_test.dat

# --- Scheduler: mq-deadline ---
sudo ./tune_io_scheduler.sh $PRIMARY_DEVICE mq-deadline
sleep 2
sudo dd if=/opt/blktrace-lab/test_100mb.dat of=/dev/null bs=64k 2>&1 | grep -E "(copied|MB/s|GB/s)"
sudo blktrace -d /dev/$PRIMARY_DEVICE -o trace_mq-deadline &
TRACE_PID=$!
sudo dd if=/dev/zero of=/opt/blktrace-lab/scheduler_test.dat bs=64k count=500 2>/dev/null
sleep 2
sudo kill $TRACE_PID 2>/dev/null
wait $TRACE_PID 2>/dev/null
sudo blkparse -i trace_mq-deadline -o parsed_mq-deadline.txt 2>/dev/null
[ -f parsed_mq-deadline.txt ] && wc -l parsed_mq-deadline.txt
sudo rm -f /opt/blktrace-lab/scheduler_test.dat

# --- Scheduler: kyber ---
sudo ./tune_io_scheduler.sh $PRIMARY_DEVICE kyber
sleep 2
sudo dd if=/opt/blktrace-lab/test_100mb.dat of=/dev/null bs=64k 2>&1 | grep -E "(copied|MB/s|GB/s)"
sudo blktrace -d /dev/$PRIMARY_DEVICE -o trace_kyber &
TRACE_PID=$!
sudo dd if=/dev/zero of=/opt/blktrace-lab/scheduler_test.dat bs=64k count=500 2>/dev/null
sleep 2
sudo kill $TRACE_PID 2>/dev/null
wait $TRACE_PID 2>/dev/null
sudo blkparse -i trace_kyber -o parsed_kyber.txt 2>/dev/null
[ -f parsed_kyber.txt ] && wc -l parsed_kyber.txt
sudo rm -f /opt/blktrace-lab/scheduler_test.dat

# --- Scheduler: bfq ---
sudo ./tune_io_scheduler.sh $PRIMARY_DEVICE bfq
sleep 2
sudo dd if=/opt/blktrace-lab/test_100mb.dat of=/dev/null bs=64k 2>&1 | grep -E "(copied|MB/s|GB/s)"
sudo blktrace -d /dev/$PRIMARY_DEVICE -o trace_bfq &
TRACE_PID=$!
sudo dd if=/dev/zero of=/opt/blktrace-lab/scheduler_test.dat bs=64k count=500 2>/dev/null
sleep 2
sudo kill $TRACE_PID 2>/dev/null
wait $TRACE_PID 2>/dev/null
sudo blkparse -i trace_bfq -o parsed_bfq.txt 2>/dev/null
[ -f parsed_bfq.txt ] && wc -l parsed_bfq.txt
sudo rm -f /opt/blktrace-lab/scheduler_test.dat

# ============================================
# Task 3.4: Queue Depth + Read-ahead Tuning
# ============================================
sudo nano optimize_queue_settings.sh
sudo chmod +x optimize_queue_settings.sh
sudo ./optimize_queue_settings.sh $PRIMARY_DEVICE

# ============================================
# Task 3.5: Validate Optimizations
# ============================================
sudo nano validate_optimizations.sh
sudo chmod +x validate_optimizations.sh
sudo ./validate_optimizations.sh $PRIMARY_DEVICE

# ============================================
# Task 3.6: Persistent Configuration
# ============================================
sudo nano make_persistent.sh
sudo chmod +x make_persistent.sh
sudo ./make_persistent.sh $PRIMARY_DEVICE

sudo systemctl start io-optimization.service
sudo systemctl status io-optimization.service --no-pager
cat /sys/block/$PRIMARY_DEVICE/queue/nr_requests
cat /sys/block/$PRIMARY_DEVICE/queue/read_ahead_kb

# ============================================
# Troubleshooting / Checks
# ============================================
ls -la /dev/$PRIMARY_DEVICE

sudo blktrace -d /dev/$PRIMARY_DEVICE -o test_trace &
TRACE_PID=$!
sleep 2
sudo kill $TRACE_PID

mount | grep debugfs
sudo mount -t debugfs debugfs /sys/kernel/debug

sudo chown -R $USER:$USER /opt/blktrace-lab
sudo chmod 755 /opt/blktrace-lab
