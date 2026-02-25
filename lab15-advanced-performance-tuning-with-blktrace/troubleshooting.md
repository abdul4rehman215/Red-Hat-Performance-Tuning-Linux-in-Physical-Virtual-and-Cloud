# 🛠 Troubleshooting Guide — Lab 15: Advanced Performance Tuning with `blktrace`

> This file captures the most common issues seen when running **blktrace/blkparse** in cloud or enterprise Linux, along with fixes used during the lab.

---

## Issue 1: Wrong device selected (loop devices like `loop0`)
### ✅ Symptoms
```bash
PRIMARY_DEVICE=$(lsblk -d -o NAME --noheadings | head -1)
echo $PRIMARY_DEVICE
# loop0
````

### 🔍 Why it happens

`lsblk` lists `loop` devices before real disks, and `head -1` picks the first entry.

### ✅ Fix (used in lab)

Select the first real disk where `TYPE=disk`:

```bash
PRIMARY_DEVICE=$(lsblk -d -o NAME,TYPE --noheadings | awk '$2=="disk"{print $1; exit}')
echo $PRIMARY_DEVICE
# nvme0n1
```

---

## Issue 2: `blktrace` fails to capture anything

### ✅ Symptoms

* trace files not created
* `blkparse` output is empty
* no events captured even during I/O load

### 🔍 Common causes

* `debugfs` not mounted
* tracing blocked in restricted environments
* not enough I/O generated during capture window

### ✅ Fix 1: Confirm `debugfs` is mounted

```bash
mount | grep debugfs
```

If not mounted:

```bash
sudo mount -t debugfs debugfs /sys/kernel/debug
```

### ✅ Fix 2: Run trace with sudo and generate I/O during trace

```bash
sudo blktrace -d /dev/nvme0n1 -o trace_test &
TRACE_PID=$!

sudo dd if=/dev/zero of=/opt/blktrace-lab/test.dat bs=1M count=100

sudo kill $TRACE_PID
wait $TRACE_PID 2>/dev/null
```

---

## Issue 3: Permission denied (trace cannot start)

### ✅ Symptoms

* `blktrace` returns permission errors
* cannot access `/sys/kernel/debug`

### 🔍 Why it happens

Kernel tracing requires elevated privileges.

### ✅ Fix

Run with sudo:

```bash
sudo blktrace -d /dev/nvme0n1 -o trace_basic
```

Also ensure your working directory permissions allow writing trace files:

```bash
sudo chown -R $USER:$USER /opt/blktrace-lab
sudo chmod 755 /opt/blktrace-lab
```

---

## Issue 4: `blkparse` can’t find input / wrong prefix used

### ✅ Symptoms

```bash
sudo blkparse -i advanced_trace -o parsed_trace.txt
# but no parsed output or error about missing files
```

### 🔍 Why it happens

`-i` expects the **prefix**, and the trace output must exist as `prefix.blktrace.*`.

### ✅ Fix

Verify files exist:

```bash
ls -la advanced_trace.blktrace.*
```

Then parse again:

```bash
sudo blkparse -i advanced_trace -o parsed_trace.txt
```

---

## Issue 5: Scheduler tuning fails / “invalid argument”

### ✅ Symptoms

```bash
echo bfq | sudo tee /sys/block/nvme0n1/queue/scheduler
# invalid argument
```

### 🔍 Why it happens

Not all schedulers are available on all devices/kernels.

### ✅ Fix

List available schedulers first:

```bash
cat /sys/block/nvme0n1/queue/scheduler
# [none] mq-deadline kyber bfq
```

Choose only from the list.

---

## Issue 6: Scheduler parameter files don’t exist

### ✅ Symptoms

Tuning script tries to write:

* `/sys/block/<dev>/queue/iosched/read_expire`
* `/sys/block/<dev>/queue/iosched/write_lat_nsec`
  …but the file is missing.

### 🔍 Why it happens

Scheduler-specific sysfs parameters vary by kernel version, scheduler, and device type.

### ✅ Fix

Handle gracefully (as in lab script):

```bash
echo 500 | sudo tee /sys/block/$DEVICE/queue/iosched/read_expire 2>/dev/null || true
```

---

## Issue 7: `fio` not installed (random I/O baseline fails)

### ✅ Symptoms

```bash
command -v fio
# not found
```

### ✅ Fix

Install fio:

```bash
sudo apt install -y fio
```

### ✅ Fallback (used in scripts)

Use dd with random seeks:

```bash
for i in {1..100}; do
  sudo dd if=/opt/blktrace-lab/test_100mb.dat of=/dev/null bs=4k count=1 skip=$((RANDOM % 1000)) 2>/dev/null
done
```

---

## Issue 8: `sysctl` errors for unsupported kernel parameters

### ✅ Symptoms

```text
sysctl: cannot stat /proc/sys/kernel/io_delay_type: No such file or directory
```

### 🔍 Why it happens

Kernel parameters differ between kernel builds/distributions.

### ✅ Fix

This is **non-fatal** if the rest applied successfully.
To verify what applied:

```bash
sudo sysctl -p /etc/sysctl.d/99-io-performance.conf
```

If needed, comment/remove the unsupported line from the sysctl file.

---

## Issue 9: Persistent settings not applied after reboot

### ✅ Symptoms

* scheduler resets
* queue depth/read-ahead revert to defaults

### ✅ Fix 1: Validate udev rule exists

```bash
cat /etc/udev/rules.d/60-io-scheduler.rules
```

Reload udev rules:

```bash
sudo udevadm control --reload-rules
sudo udevadm trigger
```

### ✅ Fix 2: Validate systemd oneshot service

```bash
sudo systemctl status io-optimization.service --no-pager
sudo systemctl start io-optimization.service
```

Confirm values:

```bash
cat /sys/block/nvme0n1/queue/nr_requests
cat /sys/block/nvme0n1/queue/read_ahead_kb
```

---

## ✅ Quick Validation Checklist

Run these after any tuning change:

```bash
cat /sys/block/nvme0n1/queue/scheduler
cat /sys/block/nvme0n1/queue/nr_requests
cat /sys/block/nvme0n1/queue/read_ahead_kb
iostat -x 1 3
fio --name=check --rw=randread --bs=4k --size=200m --runtime=10 --directory=/opt/blktrace-lab --group_reporting
```

---
