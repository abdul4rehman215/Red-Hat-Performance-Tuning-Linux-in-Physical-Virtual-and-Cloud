# scripts/update_memory.sh
#!/bin/bash
VM_NAME="performance-vm"

# Stop VM if running
sudo virsh shutdown $VM_NAME

# Wait for shutdown
sleep 10

# Edit VM configuration
sudo virsh edit $VM_NAME

echo "Memory configuration updated for $VM_NAME"
echo "Remember to add hugepages and NUMA settings manually in the editor"
