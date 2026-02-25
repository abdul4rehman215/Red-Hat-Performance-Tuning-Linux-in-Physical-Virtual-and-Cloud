#/etc/udev/rules.d/60-ioscheduler.rules (udev persistence — content I added)

# Set I/O scheduler for all SCSI/SATA devices
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/scheduler}="mq-deadline"
# Set I/O scheduler for NVMe devices
ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="none"
