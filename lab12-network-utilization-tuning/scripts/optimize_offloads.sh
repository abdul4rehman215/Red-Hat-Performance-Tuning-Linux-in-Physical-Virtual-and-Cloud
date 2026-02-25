# scripts/optimize_offloads.sh
#!/bin/bash
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -1)
echo "Optimizing offload features for interface: $INTERFACE"

# Enable beneficial offload features
echo "Enabling performance-enhancing offload features..."

# TCP Segmentation Offload
sudo ethtool -K $INTERFACE tso on 2>/dev/null && echo "TSO: enabled" || echo "TSO: not supported"

# Generic Segmentation Offload
sudo ethtool -K $INTERFACE gso on 2>/dev/null && echo "GSO: enabled" || echo "GSO: not supported"

# Generic Receive Offload
sudo ethtool -K $INTERFACE gro on 2>/dev/null && echo "GRO: enabled" || echo "GRO: not supported"

# Checksum offloading
sudo ethtool -K $INTERFACE rx on 2>/dev/null && echo "RX checksum: enabled" || echo "RX checksum: not supported"
sudo ethtool -K $INTERFACE tx on 2>/dev/null && echo "TX checksum: enabled" || echo "TX checksum: not supported"

# Scatter-gather
sudo ethtool -K $INTERFACE sg on 2>/dev/null && echo "Scatter-gather: enabled" || echo "Scatter-gather: not supported"

echo ""
echo "Current offload settings:"
ethtool -k $INTERFACE | grep -E "(tcp-segmentation-offload|generic-segmentation-offload|generic-receive-offload|rx-checksumming|tx-checksumming|scatter-gather)"
