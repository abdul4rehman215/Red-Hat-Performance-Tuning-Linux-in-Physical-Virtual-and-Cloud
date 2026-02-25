# 🛠 Troubleshooting Guide — Lab 13: Tuning Virtualization Performance (KVM/libvirt)

> This guide documents common issues encountered while tuning VM performance using **KVM/QEMU + libvirt** on Ubuntu, including CPU pinning, hugepages, ballooning, service differences, and benchmarking.

---

## Issue 1: `virt-install` warns `--location is deprecated`
### ✅ Symptoms
```text
WARNING  --location is deprecated. Use --cdrom or --location with a kernel+initrd pair.
````

### 🔍 Cause

Recent `virt-install` versions deprecate some net-install workflows or require more explicit installer inputs.

### ✅ Fix

Use a supported installation method:

* `--cdrom /path/to.iso`
* or `--location` with kernel+initrd explicitly (if required)

Example (concept):

```bash
sudo virt-install --name performance-vm --cdrom ubuntu.iso ...
```

### 🛡 Prevention

For performance labs, using a prebuilt guest image (qcow2 cloud image) is often faster and avoids installer complexity.

---

## Issue 2: `Requested bridge virbr0 but network appears inactive`

### ✅ Symptoms

```text
WARNING  Requested bridge virbr0 but network appears inactive. Attempting to start default network.
```

### 🔍 Cause

The libvirt default network (`default`) may be inactive at the time of VM creation.

### ✅ Fix

Check networks:

```bash
sudo virsh net-list --all
```

Start default network:

```bash
sudo virsh net-start default
sudo virsh net-autostart default
```

### 🛡 Prevention

Ensure `default` network is active before VM provisioning.

---

## Issue 3: VM boots into installer instead of installed OS

### ✅ Symptoms

Console shows:

```text
Ubuntu 20.04 LTS installer (serial console)
```

### 🔍 Cause

The VM was created using a net-install method (`--location`), so it boots into installation environment until install completes.

### ✅ Fix

* Complete the installation through the console
* OR attach a fully installed qcow2 image instead of installing during the lab

### 🛡 Prevention

Use an already-installed sample VM or cloud image for performance tuning labs so tests focus on tuning, not OS installation.

---

## Issue 4: CPU pinning shows vCPUs as `offline`

### ✅ Symptoms

`virsh vcpuinfo` shows:

* `State: offline`

### 🔍 Cause

The VM is shut off. Pinning can still be configured, but runtime vCPU state is offline until the VM is running.

### ✅ Fix

Start VM then re-check:

```bash
sudo virsh start performance-vm
sudo virsh vcpuinfo performance-vm
```

### 🛡 Prevention

Treat pinning as a configuration step; validate runtime state after VM starts.

---

## Issue 5: Hugepages cannot be allocated / value resets after reboot

### ✅ Symptoms

* `HugePages_Total` stays 0
* `echo 1024 > nr_hugepages` fails or does not persist

### 🔍 Cause

* Not enough free contiguous memory
* Host memory pressure
* Hugepages configured only at runtime (not persistent)

### ✅ Fix

Try allocating fewer pages:

```bash
echo 256 | sudo tee /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
```

Verify:

```bash
cat /proc/meminfo | grep -i huge
```

Persist hugepages (example approach):

* set via GRUB kernel params or sysctl/system config depending on distro

### 🛡 Prevention

Allocate hugepages early (before memory fragmentation) and document the final reserved size.

---

## Issue 6: Ballooning not working / memory target doesn’t change

### ✅ Symptoms

* `virsh setmem --live` runs but VM memory stats don’t change
* balloon stats missing in domstats

### 🔍 Cause

* guest balloon driver not loaded (`virtio_balloon`)
* balloon device not attached in VM XML
* VM not configured to allow ballooning

### ✅ Fix

Verify balloon device exists:

```bash
sudo virsh dumpxml performance-vm | grep -i balloon
```

Verify balloon stats:

```bash
sudo virsh domstats --balloon performance-vm | head -20
```

Inside guest, ensure module is loaded:

```bash
sudo modprobe virtio_balloon
lsmod | grep virtio_balloon
```

### 🛡 Prevention

Always configure both sides:

* guest driver + VM XML device.

---

## Issue 7: `Failed to restart libvirtd.service: Unit libvirtd.service not found`

### ✅ Symptoms

```text
Failed to restart libvirtd.service: Unit libvirtd.service not found.
```

### 🔍 Cause

On newer Ubuntu, libvirt services may be split into:

* `virtqemud.service`, `virtlogd.service`, and sockets
  instead of `libvirtd.service`.

### ✅ Fix

List services:

```bash
systemctl list-units | grep -E "libvirt|virtqemud" | head
```

Restart the correct daemon:

```bash
sudo systemctl restart virtqemud.service
```

### 🛡 Prevention

Always confirm service names per distribution version before applying systemctl commands.

---

## Issue 8: Benchmarks fail because tools are missing

### ✅ Symptoms

* `stress-ng: command not found`
* `sysbench: command not found`
* `netperf: command not found`

### 🔍 Cause

Performance toolchain not installed.

### ✅ Fix

Install required packages:

```bash
sudo apt update
sudo apt install -y stress-ng sysbench fio iperf3 htop iotop sysstat collectl nmon netperf memtester
```

### 🛡 Prevention

Keep a dedicated installer script (used in this lab: `install_perf_tools.sh`) and run it at the start.

---

## Issue 9: Memory balancing cron job doesn’t execute

### ✅ Symptoms

* No changes happening
* Log file not updating

### 🔍 Cause

* cron not running
* script path incorrect
* permissions for log writing under `/var/log`

### ✅ Fix

Confirm cron entry:

```bash
crontab -l
```

Ensure script is executable:

```bash
chmod +x ~/auto_balance.sh
```

Verify logging works:

```bash
sudo tail -n 20 /var/log/memory_balancing.log
```

### 🛡 Prevention

Use absolute paths in cron jobs and confirm log permissions early.

---
