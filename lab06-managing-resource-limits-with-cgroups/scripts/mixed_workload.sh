#!/bin/bash
echo "Starting mixed workload..."
# CPU component
(while true; do echo "scale=1000; 4*a(1)" | bc -l > /dev/null; done) &
CPU_WORKER=$!

# Memory component
python3 -c "
import time
data = []
for i in range(50):
 data.append(bytearray(1024*1024)) # 1MB chunks
 time.sleep(0.5)
time.sleep(10)
" &
MEM_WORKER=$!

# I/O component
(for i in {1..10}; do
 dd if=/dev/zero of=/tmp/io_test/file_$i bs=1M count=10 2>/dev/null
 sleep 1
done) &
IO_WORKER=$!

echo "Workload PIDs: CPU=$CPU_WORKER, MEM=$MEM_WORKER, IO=$IO_WORKER"
wait $CPU_WORKER $MEM_WORKER $IO_WORKER 2>/dev/null
