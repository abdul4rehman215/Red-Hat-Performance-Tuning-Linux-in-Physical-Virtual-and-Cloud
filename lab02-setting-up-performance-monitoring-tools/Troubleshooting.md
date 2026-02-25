# 🛠️ Troubleshooting Guide — Lab 02: Setting Up Performance Monitoring Tools

> This file documents common failures when installing monitoring tools, enabling sysstat, running perf, and collecting baseline logs.

---

## 1) ❌ Package Installation Fails (DNF errors)
### ✅ Problem
`dnf install` fails or cannot find packages / repositories.

### 🔎 Likely Cause
- Repository metadata is outdated
- Repos are disabled or misconfigured
- Cache is stale
- Network issues in the environment

### ✅ Fix
1) Verify repos:
```bash
sudo dnf repolist
````

2. Clean cache:

```bash
sudo dnf clean all
```

3. Retry installation:

```bash
sudo dnf install -y procps-ng sysstat dstat perf
```

---

## 2) ❌ Tool Not Found After Install (command not found)

### ✅ Problem

After installation, running `top`, `vmstat`, `iostat`, `sar`, `dstat`, or `perf` returns `command not found`.

### 🔎 Likely Cause

* Package install didn’t succeed
* PATH issues (rare on standard RHEL)
* Wrong package name

### ✅ Fix

Verify install and binary paths:

```bash
which top vmstat iostat sar dstat perf
rpm -q procps-ng sysstat dstat perf
```

---

## 3) ❌ sysstat Service Not Running / No sar Data

### ✅ Problem

`sar` shows no data or sysstat service appears not collecting.

### 🔎 Likely Cause

* sysstat service not enabled/started
* collection scripts not being triggered
* sysstat behaves differently across distros (but RHEL usually consistent)

### ✅ Fix

Enable + start sysstat:

```bash
sudo systemctl enable sysstat
sudo systemctl start sysstat
```

Restart if needed:

```bash
sudo systemctl restart sysstat
```

Check status:

```bash
sudo systemctl status sysstat
```

Manually trigger a collection cycle:

```bash
sudo /usr/lib64/sa/sa1
```

---

## 4) ❌ perf Permission Denied / perf Not Allowed

### ✅ Problem

`perf` fails unless using sudo, or shows permission restrictions.

### 🔎 Likely Cause

Perf uses kernel performance counters which may be restricted by:

* lack of privileges
* `kernel.perf_event_paranoid` value

### ✅ Fix

Run perf with sudo:

```bash
sudo perf top
sudo perf record -a sleep 10
sudo perf report
```

Temporary kernel setting adjustment (as done in lab):

```bash
echo 0 | sudo tee /proc/sys/kernel/perf_event_paranoid
```

> Note: In production, adjust cautiously and document changes.

---

## 5) ⚠️ Monitoring Tools Consume Too Many Resources

### ✅ Problem

Monitoring commands feel heavy or affect system responsiveness.

### 🔎 Likely Cause

Frequent intervals (small delay values) increase overhead.

### ✅ Fix

Use longer intervals (example used in lab):

```bash
iostat 30 5
```

Reduce scope (monitor only specific processes when possible).

---

## 6) ❌ `top -p $(pgrep -d',' httpd)` Fails (no PIDs)

### ✅ Problem

Output shows:

* `top: -p requires a list of process IDs`
* or pgrep finds nothing

### 🔎 Likely Cause

No matching process is running (example: no `httpd` on the VM).

### ✅ Fix

Confirm target process exists:

```bash
pgrep -a httpd
```

If nothing is returned, choose an active process or service:

```bash
ps aux --sort=-%cpu | head
ps aux --sort=-%mem | head
```

---

## 7) ❌ Device Not Found in iostat (`sda not found`)

### ✅ Problem

`iostat -x sda ...` returns:

* `Device: sda not found`

### 🔎 Likely Cause

Storage device name differs (NVMe devices often appear as `nvme0n1`).

### ✅ Fix

List available block devices:

```bash
lsblk
```

Then target the correct device:

```bash
iostat -x nvme0n1 2 5
```

---

## 8) ✅ CSV/Log Output Confusion (dstat output file)

### ✅ Problem

You exported dstat output to a file but aren’t sure if it worked.

### 🔎 Likely Cause

`dstat --output` writes CSV-like output while still printing to the terminal.

### ✅ Fix

Verify the output file exists:

```bash
ls -la /tmp/dstat.log
```

Preview the file:

```bash
head -n 20 /tmp/dstat.log
```

---

## ✅ Quick Verification Checklist

Use these checks after completing the lab:

### Tools present:

```bash
which top vmstat iostat sar dstat perf
```

### sysstat enabled:

```bash
sudo systemctl status sysstat
```

### Baselines captured:

```bash
ls -la ~/performance_logs/
```

### Scripts executable:

```bash
ls -la ~/performance_monitor.sh ~/performance_dashboard.sh
```

### Basic functionality tests:

```bash
timeout 5 top -b -n 1 > /dev/null && echo "✓ top working"
vmstat 1 2 > /dev/null && echo "✓ vmstat working"
iostat 1 2 > /dev/null && echo "✓ iostat working"
sar -u 1 2 > /dev/null && echo "✓ sar working"
timeout 5 dstat 1 2 > /dev/null && echo "✓ dstat working"
sudo perf list > /dev/null && echo "✓ perf working"
```
