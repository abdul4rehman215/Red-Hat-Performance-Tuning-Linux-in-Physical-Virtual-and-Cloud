# scripts/check_tcp_buffers.sh
#!/bin/bash
echo "=== Current TCP Buffer Configuration ==="
echo "Core receive buffer max: $(sysctl -n net.core.rmem_max) bytes"
echo "Core send buffer max: $(sysctl -n net.core.wmem_max) bytes"
echo "Core receive buffer default: $(sysctl -n net.core.rmem_default) bytes"
echo "Core send buffer default: $(sysctl -n net.core.wmem_default) bytes"
echo ""
echo "TCP receive buffer (min/default/max): $(sysctl -n net.ipv4.tcp_rmem)"
echo "TCP send buffer (min/default/max): $(sysctl -n net.ipv4.tcp_wmem)"
echo ""
echo "TCP window scaling: $(sysctl -n net.ipv4.tcp_window_scaling)"
echo "TCP timestamps: $(sysctl -n net.ipv4.tcp_timestamps)"
echo "TCP SACK: $(sysctl -n net.ipv4.tcp_sack)"
