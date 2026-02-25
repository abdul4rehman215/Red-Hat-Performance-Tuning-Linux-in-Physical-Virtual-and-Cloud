#!/bin/bash
# Database I/O Tuning Script

# Set I/O scheduler to deadline
echo mq-deadline > /sys/block/sda/queue/scheduler

# Configure deadline scheduler parameters
echo 1 > /sys/block/sda/queue/iosched/front_merges
echo 150 > /sys/block/sda/queue/iosched/read_expire
echo 1500 > /sys/block/sda/queue/iosched/write_expire
echo 6 > /sys/block/sda/queue/iosched/writes_starved

# Set queue depth
echo 32 > /sys/block/sda/queue/nr_requests
