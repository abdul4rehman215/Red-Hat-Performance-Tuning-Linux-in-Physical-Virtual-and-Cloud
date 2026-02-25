# scripts/calculate_buffers.sh
#!/bin/bash
echo "=== Buffer Size Calculation ==="

# Get network interface speed (in Mbps)
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -1)
SPEED=$(ethtool $INTERFACE 2>/dev/null | grep "Speed:" | awk '{print $2}' | sed 's/Mb\/s//')

if [ -z "$SPEED" ] || [ "$SPEED" = "Unknown!" ]; then
 SPEED=1000 # Default to 1Gbps if unable to detect
fi

echo "Interface: $INTERFACE"
echo "Speed: ${SPEED}Mbps"

# Calculate RTT (Round Trip Time) - using ping to gateway
GATEWAY=$(ip route | grep default | awk '{print $3}' | head -1)
RTT=$(ping -c 5 $GATEWAY 2>/dev/null | tail -1 | awk -F'/' '{print $5}' | cut -d'.' -f1)

if [ -z "$RTT" ]; then
 RTT=1 # Default to 1ms if unable to measure
fi

echo "Estimated RTT: ${RTT}ms"

# Calculate Bandwidth-Delay Product (BDP)
# BDP = Bandwidth × RTT
# Convert to bytes: (Speed in Mbps × RTT in ms × 1000) / 8
BDP=$(echo "scale=0; ($SPEED * $RTT * 1000) / 8" | bc -l 2>/dev/null || echo $((SPEED * RTT * 125)))

echo "Calculated BDP: ${BDP} bytes"

# Recommended buffer sizes (2x BDP for good performance)
RECOMMENDED_BUFFER=$((BDP * 2))

echo "Recommended buffer size: ${RECOMMENDED_BUFFER} bytes"

# Ensure minimum reasonable size
if [ $RECOMMENDED_BUFFER -lt 65536 ]; then
 RECOMMENDED_BUFFER=65536
fi

# Ensure maximum reasonable size (32MB)
if [ $RECOMMENDED_BUFFER -gt 33554432 ]; then
 RECOMMENDED_BUFFER=33554432
fi

echo "Final recommended buffer size: ${RECOMMENDED_BUFFER} bytes"
