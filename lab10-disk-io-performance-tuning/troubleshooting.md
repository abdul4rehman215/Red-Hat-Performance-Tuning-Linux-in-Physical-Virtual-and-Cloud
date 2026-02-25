# 🛠️ Troubleshooting Guide — Lab 10: Disk I/O Performance Tuning (Ubuntu 20.04)

## 1) `iostat: command not found`
**Cause:** `sysstat` package not installed.  
**Fix:**
```bash
sudo apt update
sudo apt install -y sysstat
````

**Verify:**

```bash
which iostat
iostat -V
```

---

## 2) Wrong disk path (e.g., `/sys/block/sda/...` not found)

**Symptom:**

```bash
cat: /sys/block/sda/queue/scheduler: No such file or directory
```

**Cause:** Cloud VM uses NVMe (`nvme0n1`) instead of `sda`.
**Fix:** Identify the real device and use it:

```bash
lsblk
cat /sys/block/nvme0n1/queue/scheduler
```

---

## 3) Scheduler change fails: `Invalid argument`

**Symptom:**

```bash
echo bfq | sudo tee /sys/block/nvme0n1/queue/scheduler
tee: ... Invalid argument
```

**Cause:** Scheduler not supported by this device/kernel.
**Fix:** Only choose from the list shown:

```bash
cat /sys/block/nvme0n1/queue/scheduler
```

Pick one of the displayed options (the active one is in brackets).

---

## 4) Scheduler change doesn’t persist after reboot

**Cause:** Changes to `/sys/block/.../queue/scheduler` are runtime-only.
**Fix (recommended): systemd oneshot service**

1. Create service:

```bash
sudo nano /etc/systemd/system/ioscheduler.service
```

2. Add:

```ini
[Unit]
Description=Set optimal I/O scheduler
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'echo none > /sys/block/nvme0n1/queue/scheduler'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

3. Enable + start:

```bash
sudo systemctl daemon-reload
sudo systemctl enable ioscheduler.service
sudo systemctl start ioscheduler.service
```

4. Verify:

```bash
cat /sys/block/nvme0n1/queue/scheduler
```

---

## 5) `fio: command not found`

**Cause:** fio not installed.
**Fix:**

```bash
sudo apt install -y fio
```

**Verify:**

```bash
fio --version
```

---

## 6) `hdparm` errors / warnings on NVMe

**Symptom:**

* `HDIO_DRIVE_CMD(identify) failed: Inappropriate ioctl for device`

**Cause:** `hdparm` is ATA/SATA focused; NVMe often doesn’t support those ioctls.
**Fix:** Treat it as expected; use `fio`/`iostat` for reliable NVMe testing.
Install if needed:

```bash
sudo apt install -y hdparm
```

---

## 7) Benchmark results look “too fast” or inconsistent

**Common Causes**

* Page cache effects (tests not using direct I/O)
* Background workload on the VM
* Very short test duration
* Shared cloud storage / noisy neighbors

**Fixes**

* Use direct I/O:

  * `dd ... oflag=direct` / `iflag=direct`
  * `fio ... --direct=1`
* Drop caches before a test (careful on production):

```bash
sync
echo 3 | sudo tee /proc/sys/vm/drop_caches
```

* Run multiple times and average.
* Increase runtime (e.g., `fio --runtime=30 --time_based`).

---

## 8) `Permission denied` when writing scheduler

**Cause:** Need root.
**Fix:**

```bash
echo none | sudo tee /sys/block/nvme0n1/queue/scheduler
```

**Verify current user permissions:**

```bash
id
sudo -l
```

---

## 9) `iotop: command not found`

**Fix:**

```bash
sudo apt install -y iotop
sudo iotop -o
```

---

## 10) Cleanup: test files filling disk

**Fix:**

```bash
rm -rf /tmp/iotest/*
rm -f /tmp/iotest/fio-test /tmp/iotest/perftest
```

---

## Quick Debug Checklist

```bash
lsblk
cat /sys/block/nvme0n1/queue/scheduler
iostat -x 1 3
sudo iotop -o
fio --version
```
