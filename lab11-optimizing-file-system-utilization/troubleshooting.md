# 🛠 Troubleshooting — Lab 11: Optimizing File System Utilization

> This file documents common issues encountered during filesystem tuning and benchmarking, along with practical fixes and prevention tips.

---

## Issue 1: Loop device already in use (`losetup: /dev/loopX: device busy`)
### ✅ Symptoms
- `losetup /dev/loop0 /opt/testfs.img` fails
- `mount /dev/loop0 ...` fails because the loop device is already attached

### 🔍 Cause
The loop device is still attached from a previous run or was not detached during cleanup.

### ✅ Fix
Check active loop devices:
```bash
sudo losetup -a
````

Detach the specific loop device:

```bash
sudo losetup -d /dev/loop0
```

If you do not know which loop device belongs to which image:

```bash
sudo losetup -a | grep testfs.img
```

### 🛡 Prevention

Always run cleanup at the end of the lab:

```bash
sudo umount /mnt/optimized-fs 2>/dev/null
sudo losetup -d /dev/loop0 2>/dev/null
```

---

## Issue 2: Mount fails with “wrong fs type, bad option, bad superblock”

### ✅ Symptoms

Example error:

```text
mount: /mnt/optimized-fs: wrong fs type, bad option, bad superblock on /dev/loop0...
```

### 🔍 Cause

Using unsupported or deprecated mount options (example: `nobh`, `barrier=0`) on modern ext4.

### ✅ Fix

Retry with supported performance options:

```bash
sudo mount -o noatime,nodiratime,data=writeback /dev/loop0 /mnt/optimized-fs
```

### 🛡 Prevention

Validate mount options before applying them broadly:

```bash
man mount
man ext4
```

---

## Issue 3: Permission denied writing to `/sys/...` (scheduler, read_ahead_kb)

### ✅ Symptoms

* `echo deadline > /sys/block/loop1/queue/scheduler` fails

### 🔍 Cause

Writing to sysfs requires elevated privileges.

### ✅ Fix

Use `sudo tee` instead of redirect:

```bash
echo deadline | sudo tee /sys/block/loop1/queue/scheduler
echo 4096 | sudo tee /sys/block/loop1/queue/read_ahead_kb
```

### 🛡 Prevention

Any sysfs writes should be done using:

* `sudo tee`
* or a root shell

---

## Issue 4: Benchmarks inconsistent between runs

### ✅ Symptoms

* Time results vary significantly run-to-run
* Sometimes benchmarks appear unrealistically fast

### 🔍 Cause

Filesystem caching can dramatically affect results, especially repeated reads/writes.

### ✅ Fix

Drop caches between tests:

```bash
sync
echo 3 | sudo tee /proc/sys/vm/drop_caches
```

Use `oflag=direct` and `iflag=direct` (already used in the benchmark script) to reduce cache effects in `dd`.

### 🛡 Prevention

Standardize every test run:

* same file sizes
* same cache drops
* same count of files
* same mount options
* same hardware load

---

## Issue 5: `df -h | grep ...` shows blank results for loop mounts

### ✅ Symptoms

Report section shows nothing:

```text
2. DISK USAGE COMPARISON
------------------------
```

### 🔍 Cause

Loop devices appear in `df` output as `/dev/loopX` and may not match grep patterns like `ext4-tuned`.

### ✅ Fix

Use device-based filtering:

```bash
df -h | grep -E "loop1|loop2|loop3"
```

Or show mount points directly:

```bash
df -h /mnt/ext4-tuned /mnt/xfs-tuned /mnt/btrfs-tuned
```

### 🛡 Prevention

In scripts, match mount points instead of labels:

```bash
df -h | grep -E "/mnt/ext4-tuned|/mnt/xfs-tuned|/mnt/btrfs-tuned"
```

---

## Issue 6: Cannot unmount (“target is busy”)

### ✅ Symptoms

* `umount /mnt/ext4-tuned` fails with “busy”

### 🔍 Cause

A process is still using that mount point (shell working directory, benchmark script, open file handle).

### ✅ Fix

Exit the directory first:

```bash
cd ~
```

Find processes using the mount:

```bash
sudo lsof +D /mnt/ext4-tuned 2>/dev/null | head
```

Or:

```bash
sudo fuser -vm /mnt/ext4-tuned
```

Then retry unmount:

```bash
sudo umount /mnt/ext4-tuned
```

### 🛡 Prevention

Ensure scripts `cd` out or cleanup properly at the end.

---

## Issue 7: `iostat` not found

### ✅ Symptoms

* `iostat: command not found`

### 🔍 Cause

`sysstat` package is not installed.

### ✅ Fix

Install sysstat:

```bash
sudo dnf install -y sysstat
# or
sudo yum install -y sysstat
```

### 🛡 Prevention

Verify tooling before running benchmarks:

```bash
which iostat || echo "iostat missing"
```

---

## Issue 8: Btrfs commands fail (btrfs-progs missing)

### ✅ Symptoms

* `btrfs: command not found`
* `mkfs.btrfs` missing

### 🔍 Cause

Btrfs tools not installed.

### ✅ Fix

Install tools:

```bash
sudo dnf install -y btrfs-progs
# or
sudo yum install -y btrfs-progs
```

### 🛡 Prevention

Confirm tools before creating Btrfs:

```bash
which mkfs.btrfs || echo "btrfs-progs missing"
```

---
