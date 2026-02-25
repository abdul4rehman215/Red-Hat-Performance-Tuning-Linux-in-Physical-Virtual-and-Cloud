# scripts/adjust_memory.sh
#!/bin/bash
VM_NAME="performance-vm"
NEW_MEMORY_KB=$1

if [ -z "$NEW_MEMORY_KB" ]; then
 echo "Usage: $0 <memory_in_KB>"
 echo "Example: $0 2097152 # for 2GB"
 exit 1
fi

echo "Adjusting memory for $VM_NAME to ${NEW_MEMORY_KB}KB"

# Set balloon target
sudo virsh setmem $VM_NAME $NEW_MEMORY_KB --live

# Monitor the change
sleep 5
sudo virsh dommemstat $VM_NAME

echo "Memory adjustment completed"
