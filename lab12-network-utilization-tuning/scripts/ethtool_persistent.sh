# scripts/ethtool_persistent.sh
#!/bin/bash
# Network interface optimization script
# This script should be run at boot time

INTERFACE=$(ip route | grep default | awk '{print $5}' | head -1)

if [ -z "$INTERFACE" ]; then
 echo "No default interface found"
 exit 1
fi

echo "Applying network optimizations to interface: $INTERFACE"

# Ring buffer optimization
MAX_RX=$(ethtool -g $INTERFACE | grep -A4 "Pre-set maximums" | grep "RX:" | awk '{print $2}')
MAX_TX=$(ethtool -g $INTERFACE | grep -A4 "Pre-set maximums" | grep "TX:" | awk '{print $2}')

[ ! -z "$MAX_RX" ] && [ "$MAX_RX" != "n/a" ] && ethtool -G $INTERFACE rx $MAX_RX
[ ! -z "$MAX_TX" ] && [ "$MAX_TX" != "n/a" ] && ethtool -G $INTERFACE tx $MAX_TX

# Offload features
ethtool -K $INTERFACE tso on 2>/dev/null
ethtool -K $INTERFACE gso on 2>/dev/null
ethtool -K $INTERFACE gro on 2>/dev/null
ethtool -K $INTERFACE rx on 2>/dev/null
ethtool -K $INTERFACE tx on 2>/dev/null
ethtool -K $INTERFACE sg on 2>/dev/null

# Coalescing
ethtool -C $INTERFACE adaptive-rx on adaptive-tx on 2>/dev/null
ethtool -C $INTERFACE rx-usecs 50 2>/dev/null
ethtool -C $INTERFACE tx-usecs 50 2>/dev/null
ethtool -C $INTERFACE rx-frames 32 2>/dev/null
ethtool -C $INTERFACE tx-frames 32 2>/dev/null

echo "Network optimizations applied successfully"
