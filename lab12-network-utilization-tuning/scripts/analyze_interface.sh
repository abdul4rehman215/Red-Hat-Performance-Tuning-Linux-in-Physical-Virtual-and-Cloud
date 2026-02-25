# scripts/analyze_interface.sh
#!/bin/bash
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -1)
echo "=== Network Interface Analysis ==="
echo "Interface: $INTERFACE"
echo ""
echo "Basic Interface Information:"
ethtool $INTERFACE
echo ""
echo "Ring Buffer Settings:"
ethtool -g $INTERFACE
echo ""
echo "Offload Features:"
ethtool -k $INTERFACE
echo ""
echo "Coalescing Settings:"
ethtool -c $INTERFACE
echo ""
echo "Driver Information:"
ethtool -i $INTERFACE
echo ""
echo "Statistics:"
ethtool -S $INTERFACE | head -20
