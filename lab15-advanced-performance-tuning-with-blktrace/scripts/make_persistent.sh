# scripts/make_persistent.sh
#!/bin/bash
DEVICE=${1:-sda}
echo "=== MAKING I/O OPTIMIZATIONS PERSISTENT ==="

# Create udev rule for I/O scheduler
sudo tee /etc/udev/rules.d/60-io-scheduler.rules << UDEV_EOF
# Set I/O scheduler for block devices
ACTION=="add|change", KERNEL=="sd*", ATTR{queue/scheduler}="mq-deadline"
ACTION=="add|change", KERNEL=="nvme*", ATTR{queue/scheduler}="none"
UDEV_EOF

# Create systemd service for queue optimizations
sudo tee /etc/systemd/system/io-optimization.service << SYSTEMD_EOF
[Unit]
Description=I/O Performance Optimizations
After=multi-user.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/local/bin/apply-io-optimizations.sh

[Install]
WantedBy=multi-user.target
SYSTEMD_EOF

# Create the optimization script
sudo tee /usr/local/bin/apply-io-optimizations.sh << OPT_EOF
#!/bin/bash
# Apply I/O optimizations to all block devices
for device in \$(lsblk -d -o NAME --noheadings); do
  # Skip loop and ram devices
  if [[ \$device =~ ^(loop|ram) ]]; then
    continue
  fi

  # Set queue depth
  if [ -f /sys/block/\$device/queue/nr_requests ]; then
    echo 128 > /sys/block/\$device/queue/nr_requests
  fi

  # Set read-ahead
  if [ -f /sys/block/\$device/queue/read_ahead_kb ]; then
    echo 512 > /sys/block/\$device/queue/read_ahead_kb
  fi

  # Additional optimizations for SSDs
  if [ -f /sys/block/\$device/queue/rotational ]; then
    rotational=\$(cat /sys/block/\$device/queue/rotational)
    if [ "\$rotational" = "0" ]; then
      # SSD optimizations
      echo 0 > /sys/block/\$device/queue/add_random 2>/dev/null || true
      echo 1 > /sys/block/\$device/queue/nomerges 2>/dev/null || true
    fi
  fi
done
logger "I/O optimizations applied successfully"
OPT_EOF

sudo chmod +x /usr/local/bin/apply-io-optimizations.sh

# Enable the service
sudo systemctl daemon-reload
sudo systemctl enable io-optimization.service

# Create sysctl configuration for kernel parameters
sudo tee /etc/sysctl.d/99-io-performance.conf << SYSCTL_EOF
# I/O Performance Tuning Parameters
# Virtual memory settings
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
vm.dirty_expire_centisecs = 3000
vm.dirty_writeback_centisecs = 500

# Kernel I/O settings
kernel.io_delay_type = 1

# Network and I/O related
net.core.busy_read = 50
net.core.busy_poll = 50
SYSCTL_EOF

# Apply sysctl settings
sudo sysctl -p /etc/sysctl.d/99-io-performance.conf

echo "Persistent configuration created successfully!"
echo "The following components have been configured:"
echo "1. udev rules for I/O scheduler (/etc/udev/rules.d/60-io-scheduler.rules)"
echo "2. systemd service for queue optimizations (/etc/systemd/system/io-optimization.service)"
echo "3. Optimization script (/usr/local/bin/apply-io-optimizations.sh)"
echo "4. Kernel parameters (/etc/sysctl.d/99-io-performance.conf)"
echo
echo "To test the persistent configuration:"
echo "sudo systemctl start io-optimization.service"
echo "sudo systemctl status io-optimization.service"
