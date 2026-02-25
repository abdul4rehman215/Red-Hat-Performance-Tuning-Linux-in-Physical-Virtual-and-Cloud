# scripts/setup_ballooning.sh
#!/bin/bash
VM_NAME="performance-vm"

# Shutdown VM
sudo virsh shutdown $VM_NAME
sleep 15

# Add balloon device
sudo virsh attach-device $VM_NAME --file balloon_config.xml --config

# Start VM
sudo virsh start $VM_NAME

echo "Memory ballooning enabled for $VM_NAME"
