#!/bin/bash
echo "=== Kernel Parameter Validation ==="
echo "Timestamp: $(date)"
echo
CONFIG_FILE="/etc/sysctl.d/99-performance-tuning.conf"
ERRORS=0
echo "Validating configuration from: $CONFIG_FILE"
echo

# Function to check parameter
check_param() {
 local param=$1
 local expected=$2
 local current=$(sysctl -n $param 2>/dev/null)

 if [ "$current" = "$expected" ]; then
  echo "✓ $param = $current (OK)"
 else
  echo "✗ $param = $current (Expected: $expected)"
  ((ERRORS++))
 fi
}

# Check memory parameters
echo "=== Memory Parameters ==="
check_param "vm.swappiness" "10"
check_param "vm.dirty_ratio" "15"
check_param "vm.dirty_background_ratio" "5"
check_param "vm.vfs_cache_pressure" "150"
echo

# Check network parameters
echo "=== Network Parameters ==="
check_param "net.core.rmem_max" "16777216"
check_param "net.core.wmem_max" "16777216"
check_param "net.core.somaxconn" "1024"
echo

echo "=== Validation Summary ==="
if [ $ERRORS -eq 0 ]; then
 echo "✓ All parameters configured correctly!"
else
 echo "✗ Found $ERRORS configuration errors"
fi
