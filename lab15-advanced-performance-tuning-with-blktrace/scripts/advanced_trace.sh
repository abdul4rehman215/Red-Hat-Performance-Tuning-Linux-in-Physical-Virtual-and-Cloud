# scripts/advanced_trace.sh
#!/bin/bash
DEVICE=${1:-sda}
DURATION=${2:-60}
OUTPUT_PREFIX="advanced_trace"

echo "Starting advanced blktrace on /dev/$DEVICE for $DURATION seconds..."

# Start blktrace with comprehensive options
blktrace -d /dev/$DEVICE \
  -o $OUTPUT_PREFIX \
  -b 512 \
  -n 8 \
  -a issue,complete,queue,requeue &

TRACE_PID=$!
echo "Blktrace PID: $TRACE_PID"

# Wait for specified duration
sleep $DURATION

# Stop tracing
kill $TRACE_PID
wait $TRACE_PID 2>/dev/null

echo "Trace completed. Files generated:"
ls -la ${OUTPUT_PREFIX}.*
