# scripts/monitor_balloon.sh
#!/bin/bash
VM_NAME="performance-vm"

echo "=== Memory Ballooning Status ==="
echo "Host Memory Usage:"
free -h

echo -e "\nVM Memory Statistics:"
sudo virsh dommemstat $VM_NAME

echo -e "\nBalloon Memory Info:"
sudo virsh dominfo $VM_NAME | grep -i memory

echo -e "\nDetailed Memory Stats:"
sudo virsh domstats --balloon $VM_NAME
