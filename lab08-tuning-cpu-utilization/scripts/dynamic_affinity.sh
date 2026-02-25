#!/bin/bash
# Start a long-running process
python3 cpu_intensive.py 120 &
PID=$!
echo "Started process PID: $PID"

# Initial affinity - single core
echo "Setting initial affinity to core 0"
taskset -cp 0 $PID
sleep 20

# Expand to two cores
echo "Expanding affinity to cores 0,1"
taskset -cp 0,1 $PID
sleep 20

# Move to different cores
echo "Moving to cores 2,3"
taskset -cp 2,3 $PID
sleep 20

# Allow all cores
echo "Allowing all cores"
taskset -cp 0-3 $PID
sleep 20

# Back to single core
echo "Restricting to core 1"
taskset -cp 1 $PID

wait $PID
echo "Dynamic affinity test completed"
