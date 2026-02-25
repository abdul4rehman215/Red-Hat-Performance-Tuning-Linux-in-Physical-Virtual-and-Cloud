# scripts/optimize_coalescing.sh
#!/bin/bash
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -1)
echo "Optimizing interrupt coalescing for interface: $INTERFACE"
echo "Current coalescing settings:"
ethtool -c $INTERFACE

# Optimize coalescing parameters for throughput
# These values balance latency and throughput
echo ""
echo "Applying optimized coalescing settings..."

# Set adaptive coalescing if supported
sudo ethtool -C $INTERFACE adaptive-rx on adaptive-tx on 2>/dev/null \
  && echo "Adaptive coalescing: enabled" || echo "Adaptive coalescing: not supported"

# Set reasonable static values if adaptive is not supported
sudo ethtool -C $INTERFACE rx-usecs 50 2>/dev/null \
  && echo "RX interrupt delay: 50 usecs" || echo "RX interrupt delay: not configurable"
sudo ethtool -C $INTERFACE tx-usecs 50 2>/dev/null \
  && echo "TX interrupt delay: 50 usecs" || echo "TX interrupt delay: not configurable"

# Set frame limits
sudo ethtool -C $INTERFACE rx-frames 32 2>/dev/null \
  && echo "RX frame limit: 32" || echo "RX frame limit: not configurable"
sudo ethtool -C $INTERFACE tx-frames 32 2>/dev/null \
  && echo "TX frame limit: 32" || echo "TX frame limit: not configurable"

echo ""
echo "New coalescing settings:"
ethtool -c $INTERFACE
