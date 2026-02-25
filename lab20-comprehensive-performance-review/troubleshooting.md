# 🛠️ Troubleshooting Guide - Lab 20: Comprehensive Performance Review

> This document lists common issues faced during **holistic performance monitoring + tuning**, along with **quick fixes** and **verification commands**.

---

## 🧰 1) Tools Missing / Command Not Found

### ✅ Symptoms
- `iostat: command not found`
- `sar: command not found`
- `htop: command not found`
- `bc: command not found`

### ✅ Fix (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install -y sysstat htop bc
````

### ✅ Verify

```bash
which iostat sar htop bc
sar -V
iostat -V
```

---

## 📉 2) `sar` Shows No Data / Empty Output

### ✅ Symptoms

* `sar -u` prints nothing useful
* `/var/log/sa/` missing or empty

### ✅ Cause

`sar` needs `sysstat` scheduled collectors enabled.

### ✅ Fix (Ubuntu)

```bash
sudo systemctl enable --now sysstat
sudo systemctl status sysstat --no-pager
```

### ✅ Verify

```bash
ls -la /var/log/sysstat/ 2>/dev/null || true
ls -la /var/log/sa/ 2>/dev/null || true
sar -u 1 3
```

---

## 🧾 3) Monitoring Script Runs, But Files Are Empty

### ✅ Symptoms

* Output files exist but `0 bytes`
* `top_output.txt` / `iostat_output.txt` not filling

### ✅ Causes

* Script killed early
* Permission issues writing to directory
* Wrong `-n` count values
* Background jobs terminated

### ✅ Fix

1. Ensure directory is writable:

```bash
sudo chown -R $USER:$USER /opt/performance-review
```

2. Run script in foreground once:

```bash
bash -x ./scripts/performance_monitor.sh
```

3. Ensure processes are alive while script runs:

```bash
ps -ef | egrep "top -b|iostat -x|sar -u|vmstat" | grep -v grep
```

---

## 🔥 4) Stress Scripts Don’t Generate Load

### ✅ Symptoms

* CPU stays idle during `cpu_stress.sh`
* Disk util stays low during `io_stress.sh`

### ✅ Common Causes

* Stress job ended instantly
* Background tasks not actually running
* Cloud burst CPU drops frequency under policy

### ✅ Fix / Verify CPU Stress

```bash
./scripts/cpu_stress.sh &
top -o %CPU
```

If `factor` is too light, use `yes` temporarily:

```bash
yes > /dev/null &
yes > /dev/null &
sleep 30
killall yes
```

### ✅ Fix / Verify I/O Stress

```bash
./scripts/io_stress.sh &
iostat -x 1 5
```

---

## 💾 5) Disk Metrics Show Weird Devices / Missing Scheduler

### ✅ Symptoms

* Scheduler path not found
* `lsblk` shows only `loop*` or containers overlay devices
* `/sys/block/<disk>/queue/scheduler` missing

### ✅ Cause

Some virtualized environments hide scheduler features or disk naming differs (`nvme0n1`, `xvda`, etc.)

### ✅ Fix

List true disks:

```bash
lsblk -d -o NAME,TYPE,SIZE | awk '$2=="disk"{print}'
```

Check scheduler only for actual disks:

```bash
for d in $(lsblk -d -n -o NAME,TYPE | awk '$2=="disk"{print $1}'); do
  echo "$d: $(cat /sys/block/$d/queue/scheduler 2>/dev/null || echo N/A)"
done
```

---

## 🧠 6) Tuning Script Applies But Values Revert After Reboot

### ✅ Symptoms

* `/proc/sys/...` values return to defaults after reboot

### ✅ Cause

Runtime tuning isn’t persistent unless configured in sysctl files.

### ✅ Fix

Ensure persistent config exists:

```bash
cat /etc/sysctl.d/99-performance-tuning.conf
```

Re-apply sysctl:

```bash
sudo sysctl --system
```

Verify values:

```bash
cat /proc/sys/vm/swappiness
cat /proc/sys/vm/dirty_ratio
cat /proc/sys/net/core/rmem_max
```

---

## ❌ 7) “Permission Denied” Writing to `/proc/sys/...`

### ✅ Symptoms

* `Permission denied` when writing sysctl values

### ✅ Fix

Run with sudo:

```bash
sudo ./scripts/apply_tuning.sh
```

Or apply individually:

```bash
echo 10 | sudo tee /proc/sys/vm/swappiness
echo 15 | sudo tee /proc/sys/vm/dirty_ratio
```

---

## 🌐 8) `iperf3` Network Test Fails

### ✅ Symptoms

* Script prints “Network test skipped”
* `iperf3: command not found`

### ✅ Fix

```bash
sudo apt update
sudo apt install -y iperf3
```

### ✅ Verify

```bash
iperf3 --version
iperf3 -s -D
iperf3 -c localhost -t 3
pkill iperf3
```

---

## 🧮 9) Comparison Script Fails to Find Baseline or Post-Tuning Directory

### ✅ Symptoms

* `Error: Could not find baseline or post-tuning data`

### ✅ Causes

* Monitoring directory naming changed
* Post-tuning folder not created
* Running from wrong path

### ✅ Fix

Check directories exist:

```bash
ls -lah /opt/performance-review/monitoring/
ls -lah /opt/performance-review/ | grep post_tuning
```

Re-run test script to create post-tuning directory:

```bash
./scripts/post_tuning_test.sh
```

---

## 📌 10) Report Values Look “Unfair” (Baseline vs Post-Tuning)

### ✅ Symptoms

* Baseline CPU is huge (stress load)
* Post-tuning CPU is low (idle)

### ✅ Explanation

Baseline was captured **under stress**, post-tuning test may run **under low load**.

### ✅ Correct Validation Method

To compare properly:

1. Run the *same stress workload* after tuning
2. Capture monitoring again
3. Compare apples-to-apples:

   * same duration
   * same stress
   * same tools + sampling rate

---

## ✅ Quick “Health Checklist” Commands

Run these if you want a fast sanity check:

```bash
uptime
free -h
df -h
top -bn1 | head -20
iostat -x 1 2
vmstat 1 3
sar -u 1 3
cat /proc/sys/vm/swappiness
cat /proc/sys/net/core/rmem_max
```

---

