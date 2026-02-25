# scripts/auto_balance.sh
#!/bin/bash
VM_NAME="performance-vm"
LOG_FILE="/var/log/memory_balancing.log"

# Function to log with timestamp
log_message() {
 echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | sudo tee -a $LOG_FILE
}

# Get host memory usage percentage
get_host_memory_usage() {
 free | awk 'NR==2{printf "%.0f", $3*100/$2}'
}

# Get VM memory usage
get_vm_memory_usage() {
 sudo virsh dommemstat $VM_NAME | awk '/actual/ {print $2}'
}

# Main balancing logic
balance_memory() {
 HOST_MEM_USAGE=$(get_host_memory_usage)
 VM_CURRENT_MEM=$(get_vm_memory_usage)

 log_message "Host memory usage: ${HOST_MEM_USAGE}%"
 log_message "VM current memory: ${VM_CURRENT_MEM}KB"

 if [ $HOST_MEM_USAGE -gt 80 ]; then
  # High host memory usage - reduce VM memory
  NEW_MEM=$((VM_CURRENT_MEM - 524288)) # Reduce by 512MB
  if [ $NEW_MEM -gt 1048576 ]; then # Don't go below 1GB
   sudo virsh setmem $VM_NAME $NEW_MEM --live
   log_message "Reduced VM memory to ${NEW_MEM}KB due to high host usage"
  fi
 elif [ $HOST_MEM_USAGE -lt 50 ]; then
  # Low host memory usage - can increase VM memory
  NEW_MEM=$((VM_CURRENT_MEM + 262144)) # Increase by 256MB
  if [ $NEW_MEM -lt 4194304 ]; then # Don't exceed 4GB
   sudo virsh setmem $VM_NAME $NEW_MEM --live
   log_message "Increased VM memory to ${NEW_MEM}KB due to low host usage"
  fi
 fi
}

# Run balancing
balance_memory
