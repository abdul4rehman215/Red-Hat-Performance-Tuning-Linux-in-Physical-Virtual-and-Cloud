#!/bin/bash
echo "Starting I/O stress test..."
# Write test
echo "Testing write performance..."
dd if=/dev/zero of=/tmp/io_test/testfile bs=1M count=100 2>&1 | grep -E "(copied|MB/s)"
# Read test
echo "Testing read performance..."
dd if=/tmp/io_test/testfile of=/dev/null bs=1M 2>&1 | grep -E "(copied|MB/s)"
# Cleanup
rm -f /tmp/io_test/testfile
