# scripts/tune_io_scheduler.sh
#!/bin/bash
DEVICE=${1:-sda}
SCHEDULER=${2:-mq-deadline}

if [ ! -f /sys/block/$DEVICE/queue/scheduler ]; then
  echo "Error: Device $DEVICE not found or scheduler not configurable"
  exit 1
fi

echo "Current scheduler for $DEVICE:"
cat /sys/block/$DEVICE/queue/scheduler

echo "Available schedulers:"
cat /sys/block/$DEVICE/queue/scheduler | tr '[]' ' ' | tr ' ' '\n' | grep -v '^$'

echo "Changing scheduler to: $SCHEDULER"
echo $SCHEDULER | sudo tee /sys/block/$DEVICE/queue/scheduler

echo "New scheduler setting:"
cat /sys/block/$DEVICE/queue/scheduler

# Configure scheduler-specific parameters
case $SCHEDULER in
  "mq-deadline")
    echo "Configuring mq-deadline parameters..."
    echo 500 | sudo tee /sys/block/$DEVICE/queue/iosched/read_expire 2>/dev/null || true
    echo 5000 | sudo tee /sys/block/$DEVICE/queue/iosched/write_expire 2>/dev/null || true
    echo 16 | sudo tee /sys/block/$DEVICE/queue/iosched/writes_starved 2>/dev/null || true
    ;;
  "kyber")
    echo "Configuring kyber parameters..."
    echo 2000000 | sudo tee /sys/block/$DEVICE/queue/iosched/read_lat_nsec 2>/dev/null || true
    echo 10000000 | sudo tee /sys/block/$DEVICE/queue/iosched/write_lat_nsec 2>/dev/null || true
    ;;
  "bfq")
    echo "Configuring BFQ parameters..."
    echo 0 | sudo tee /sys/block/$DEVICE/queue/iosched/slice_idle 2>/dev/null || true
    echo 8 | sudo tee /sys/block/$DEVICE/queue/iosched/fifo_expire_sync 2>/dev/null || true
    ;;
esac

echo "Scheduler configuration completed."
