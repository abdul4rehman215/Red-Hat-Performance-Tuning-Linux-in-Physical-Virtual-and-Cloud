# scripts/performance_comparison.sh
#!/bin/bash
VM_NAME="performance-vm"
COMPARISON_DIR="/tmp/performance_comparison"

mkdir -p $COMPARISON_DIR

# Function to run quick performance test
run_quick_test() {
 local test_name=$1
 local output_file=$2

 echo "Running $test_name test..."

 # Quick CPU test
 echo "=== CPU Test ===" >> "$output_file"
 sysbench cpu --cpu-max-prime=10000 --threads=2 run | grep -E "(events per second|total time)" >> "$output_file"

 # Quick memory test
 echo "=== Memory Test ===" >> "$output_file"
 sysbench memory --memory-block-size=1K --memory-total-size=512M run | grep -E "(transferred|total time)" >> "$output_file"

 # VM resource usage
 echo "=== VM Resource Usage ===" >> "$output_file"
 sudo virsh domstats $VM_NAME >> "$output_file"
}

# Test with current configuration
echo "Testing current optimized configuration..."
run_quick_test "Optimized" "$COMPARISON_DIR/optimized_results.log"

echo "Performance comparison completed"
echo "Results saved in $COMPARISON_DIR"
