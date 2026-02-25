#!/bin/bash
# Lab 06 - Managing Resource Limits with cgroups (v2)
# Commands Executed During Lab (Sequential)

# ------------------------------
# Task 1: Verify cgroups version + mount
# ------------------------------

mount | grep cgroup
ls -la /sys/fs/cgroup/
systemctl --version

# Explore controllers and hierarchy
cd /sys/fs/cgroup
cat cgroup.controllers
cat cgroup.procs | head
cat cgroup.subtree_control

# ------------------------------
# Task 1.3: Create custom cgroup
# ------------------------------

sudo mkdir /sys/fs/cgroup/lab6_demo
ls -la /sys/fs/cgroup/lab6_demo/
cat /sys/fs/cgroup/lab6_demo/cgroup.controllers

# ------------------------------
# Task 2: CPU limits
# ------------------------------

echo "+cpu" | sudo tee /sys/fs/cgroup/cgroup.subtree_control
cat /sys/fs/cgroup/lab6_demo/cgroup.controllers

echo "50" | sudo tee /sys/fs/cgroup/lab6_demo/cpu.weight
echo "50000 100000" | sudo tee /sys/fs/cgroup/lab6_demo/cpu.max
cat /sys/fs/cgroup/lab6_demo/cpu.weight
cat /sys/fs/cgroup/lab6_demo/cpu.max

# Create CPU stress script
nano /tmp/cpu_stress.sh
chmod +x /tmp/cpu_stress.sh

# Run CPU stress in background + capture PID
/tmp/cpu_stress.sh &
CPU_PID=$!
echo $CPU_PID

# Add the process to our cgroup
echo $CPU_PID | sudo tee /sys/fs/cgroup/lab6_demo/cgroup.procs

# Monitor CPU usage
top -p $CPU_PID

# CPU stats
cat /sys/fs/cgroup/lab6_demo/cpu.stat
watch -n 1 cat /sys/fs/cgroup/lab6_demo/cpu.stat

# Stop stress test
kill $CPU_PID

# ------------------------------
# Task 3: Memory limits
# ------------------------------

echo "+memory" | sudo tee /sys/fs/cgroup/cgroup.subtree_control
cat /sys/fs/cgroup/lab6_demo/cgroup.controllers

echo "104857600" | sudo tee /sys/fs/cgroup/lab6_demo/memory.max
echo "83886080" | sudo tee /sys/fs/cgroup/lab6_demo/memory.high
cat /sys/fs/cgroup/lab6_demo/memory.max
cat /sys/fs/cgroup/lab6_demo/memory.high

# Create memory stress script (python)
nano /tmp/memory_stress.py
chmod +x /tmp/memory_stress.py

# Run memory stress + add to cgroup
python3 /tmp/memory_stress.py &
MEMORY_PID=$!
echo $MEMORY_PID | sudo tee /sys/fs/cgroup/lab6_demo/cgroup.procs

# Memory monitoring
cat /sys/fs/cgroup/lab6_demo/memory.current
cat /sys/fs/cgroup/lab6_demo/memory.stat | head -20
watch -n 1 "echo 'Current:'; cat /sys/fs/cgroup/lab6_demo/memory.current; echo 'Events:'; cat /sys/fs/cgroup/lab6_demo/memory.events"

# Cleanup memory stress (if still running)
kill $MEMORY_PID 2>/dev/null || true

# ------------------------------
# Task 4: I/O limits
# ------------------------------

echo "+io" | sudo tee /sys/fs/cgroup/cgroup.subtree_control
cat /sys/fs/cgroup/lab6_demo/cgroup.controllers

# Find root device major:minor (for io.max)
df / | tail -1 | awk '{print $1}' | xargs lsblk -no MAJOR:MINOR

DEVICE=$(df / | tail -1 | awk '{print $1}' | xargs lsblk -no MAJOR:MINOR | tr -d ' ')
echo "Device: $DEVICE"

# Apply throttles
echo "$DEVICE rbps=10485760" | sudo tee /sys/fs/cgroup/lab6_demo/io.max
echo "$DEVICE wbps=5242880" | sudo tee -a /sys/fs/cgroup/lab6_demo/io.max
cat /sys/fs/cgroup/lab6_demo/io.max

# I/O stress script
mkdir -p /tmp/io_test
nano /tmp/io_stress.sh
chmod +x /tmp/io_stress.sh

# Run I/O test without cgroup association (baseline)
echo "Running I/O test WITHOUT limits:"
/tmp/io_stress.sh

# Run I/O test with cgroup association
echo "Running I/O test WITH limits:"
/tmp/io_stress.sh &
IO_PID=$!
echo $IO_PID | sudo tee /sys/fs/cgroup/lab6_demo/cgroup.procs
wait $IO_PID

# I/O stats
cat /sys/fs/cgroup/lab6_demo/io.stat

# Watch io.stat during another test
watch -n 1 cat /sys/fs/cgroup/lab6_demo/io.stat &
WATCH_PID=$!

/tmp/io_stress.sh &
IO_PID=$!
echo $IO_PID | sudo tee /sys/fs/cgroup/lab6_demo/cgroup.procs
wait $IO_PID

kill $WATCH_PID 2>/dev/null || true

# ------------------------------
# Task 5: Comprehensive monitor + mixed workload + tuning
# ------------------------------

nano /tmp/cgroup_monitor.sh
chmod +x /tmp/cgroup_monitor.sh

/tmp/cgroup_monitor.sh &
MONITOR_PID=$!

nano /tmp/mixed_workload.sh
chmod +x /tmp/mixed_workload.sh

/tmp/mixed_workload.sh &
WORKLOAD_PID=$!
echo $WORKLOAD_PID | sudo tee /sys/fs/cgroup/lab6_demo/cgroup.procs

sleep 10

# Fine-tune limits
echo "75000 100000" | sudo tee /sys/fs/cgroup/lab6_demo/cpu.max
echo "157286400" | sudo tee /sys/fs/cgroup/lab6_demo/memory.max
echo "Limits adjusted - observe the changes in the monitor"

sleep 15

# Stop monitor + workload
kill $MONITOR_PID $WORKLOAD_PID 2>/dev/null || true

# ------------------------------
# Task 5.3: Persistent config via systemd unit
# ------------------------------

sudo tee /etc/systemd/system/lab6-cgroup.service << 'EOF'
[Unit]
Description=Lab 6 cgroup Configuration
After=multi-user.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/bash -c 'mkdir -p /sys/fs/cgroup/lab6_demo && \
 echo "+cpu +memory +io" > /sys/fs/cgroup/cgroup.subtree_control && \
 echo "50000 100000" > /sys/fs/cgroup/lab6_demo/cpu.max && \
 echo "50" > /sys/fs/cgroup/lab6_demo/cpu.weight && \
 echo "104857600" > /sys/fs/cgroup/lab6_demo/memory.max && \
 echo "83886080" > /sys/fs/cgroup/lab6_demo/memory.high'

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable lab6-cgroup.service
sudo systemctl start lab6-cgroup.service
sudo systemctl status lab6-cgroup.service

# ------------------------------
# Task 6.1: Web server scenario
# ------------------------------

nano /tmp/web_server_sim.py

sudo mkdir -p /sys/fs/cgroup/webserver
echo "+cpu +memory +io" | sudo tee /sys/fs/cgroup/cgroup.subtree_control

echo "30000 100000" | sudo tee /sys/fs/cgroup/webserver/cpu.max
echo "52428800" | sudo tee /sys/fs/cgroup/webserver/memory.max

python3 /tmp/web_server_sim.py &
WEB_PID=$!
echo $WEB_PID | sudo tee /sys/fs/cgroup/webserver/cgroup.procs

echo "Web server started with PID $WEB_PID"
echo "Test with: curl http://localhost:8080"

for i in {1..20}; do
  curl -s http://localhost:8080 > /dev/null &
done

sleep 10
kill $WEB_PID 2>/dev/null || true

# ------------------------------
# Task 6.2: Troubleshooting helper
# ------------------------------

nano /tmp/cgroup_troubleshoot.sh
chmod +x /tmp/cgroup_troubleshoot.sh
/tmp/cgroup_troubleshoot.sh

# ------------------------------
# Task 6.3: Performance comparison
# ------------------------------

nano /tmp/performance_comparison.sh
chmod +x /tmp/performance_comparison.sh
/tmp/performance_comparison.sh

# ------------------------------
# Cleanup
# ------------------------------

sudo pkill -f "cpu_stress\|memory_stress\|io_stress\|web_server_sim" 2>/dev/null || true

rm -rf /tmp/io_test
rm -f /tmp/cpu_stress.sh /tmp/memory_stress.py /tmp/io_stress.sh
rm -f /tmp/mixed_workload.sh /tmp/web_server_sim.py
rm -f /tmp/cgroup_monitor.sh /tmp/cgroup_troubleshoot.sh
rm -f /tmp/performance_comparison.sh

sudo rmdir /sys/fs/cgroup/lab6_demo 2>/dev/null || true
sudo rmdir /sys/fs/cgroup/webserver 2>/dev/null || true

sudo systemctl stop lab6-cgroup.service 2>/dev/null || true
sudo systemctl disable lab6-cgroup.service 2>/dev/null || true
sudo rm -f /etc/systemd/system/lab6-cgroup.service
sudo systemctl daemon-reload

echo "Cleanup completed successfully!"
