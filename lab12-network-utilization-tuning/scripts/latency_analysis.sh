# scripts/latency_analysis.sh
#!/bin/bash
SERVER_IP="172.31.20.10" # Replace with your server IP
LATENCY_FILE="latency_analysis.txt"

echo "=== NETWORK LATENCY ANALYSIS ===" > $LATENCY_FILE
echo "Target Server: $SERVER_IP" >> $LATENCY_FILE
echo "Test Date: $(date)" >> $LATENCY_FILE
echo "" >> $LATENCY_FILE

# Basic ping test
echo "=== Basic Ping Test (1000 packets) ===" >> $LATENCY_FILE
ping -c 1000 -i 0.01 $SERVER_IP >> $LATENCY_FILE
echo "" >> $LATENCY_FILE

# Different packet sizes
for size in 64 128 256 512 1024 1500; do
  echo "=== Ping Test with ${size} byte packets ===" >> $LATENCY_FILE
  ping -c 100 -s $size $SERVER_IP >> $LATENCY_FILE
  echo "" >> $LATENCY_FILE
done

# Flood ping (requires root)
if [ "$EUID" -eq 0 ]; then
  echo "=== Flood Ping Test ===" >> $LATENCY_FILE
  ping -f -c 1000 $SERVER_IP >> $LATENCY_FILE
  echo "" >> $LATENCY_FILE
fi

# hping3 test if available
if command -v hping3 &> /dev/null; then
  echo "=== TCP SYN Latency Test ===" >> $LATENCY_FILE
  hping3 -S -c 100 -p 80 $SERVER_IP >> $LATENCY_FILE
  echo "" >> $LATENCY_FILE
fi

echo "Latency analysis completed. Results saved to $LATENCY_FILE"
