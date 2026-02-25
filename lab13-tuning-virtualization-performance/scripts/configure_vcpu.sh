# scripts/configure_vcpu.sh
#!/bin/bash
VM_NAME="performance-vm"
VCPUS=4
MEMORY=4096

# Create new VM with optimized settings
sudo virt-install \
 --name $VM_NAME \
 --ram $MEMORY \
 --vcpus $VCPUS,maxvcpus=8,sockets=1,cores=4,threads=1 \
 --cpu host-passthrough \
 --disk path=/var/lib/libvirt/images/$VM_NAME.qcow2,size=20,format=qcow2 \
 --network bridge=virbr0 \
 --graphics none \
 --console pty,target_type=serial \
 --location 'http://archive.ubuntu.com/ubuntu/dists/focal/main/installer-amd64/' \
 --extra-args 'console=ttyS0,115200n8 serial' \
 --noautoconsole

echo "VM $VM_NAME created with optimized vCPU configuration"
