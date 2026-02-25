# scripts/io_load_generator.sh
#!/bin/bash
# I/O Load Generator Script
TESTDIR="/opt/blktrace-lab"
DURATION=${1:-30}

echo "Starting I/O load generation for $DURATION seconds..."

# Sequential read test
dd if=$TESTDIR/test_100mb.dat of=/dev/null bs=4k &

# Sequential write test
dd if=/dev/zero of=$TESTDIR/temp_write.dat bs=4k count=1000 &

# Random read test using dd with skip
for i in {1..100}; do
  dd if=$TESTDIR/test_100mb.dat of=/dev/null bs=4k count=1 skip=$((RANDOM % 1000)) 2>/dev/null &
done

# Wait for specified duration
sleep $DURATION

# Clean up background processes
pkill -f "dd if=$TESTDIR"
rm -f $TESTDIR/temp_write.dat

echo "I/O load generation completed."
