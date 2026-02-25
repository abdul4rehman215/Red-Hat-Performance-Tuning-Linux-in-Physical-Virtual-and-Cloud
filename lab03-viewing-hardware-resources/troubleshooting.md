# 🛠️ Troubleshooting Guide — Lab 03: Viewing Hardware Resources

> This guide covers common issues when running CPU/memory/storage inventory commands, installing missing tools, and collecting baseline reports.

---

## 1) ❌ `lshw not found`
### ✅ Problem
Running:
```bash
command -v lshw
````

returns:
`lshw not found`

### 🔎 Likely Cause

Minimal cloud images often do not include `lshw` by default.

### ✅ Fix

Install `lshw`:

```bash id="nqgkib"
sudo dnf install -y lshw
```

Then verify:

```bash id="w7dtaf"
lshw -short
```

---

## 2) ❌ `htop: command not found`

### ✅ Problem

Running:

```bash
htop
```

returns:
`-bash: htop: command not found`

### 🔎 Likely Cause

`htop` is not installed by default in many environments.

### ✅ Fix

Install `htop`:

```bash id="sl0a69"
sudo dnf install -y htop
```

Then run:

```bash id="22q8hd"
htop
```

---

## 3) ❌ Permission Denied / Incomplete Hardware Details

### ✅ Problem

Hardware inventory commands do not show complete details, or access is denied.

### 🔎 Likely Cause

* Some hardware inventory requires privileged access
* Virtual machines hide certain physical hardware details (expected behavior)

### ✅ Fix

Use sudo for privileged inventory:

```bash id="j0z2b2"
sudo lshw
sudo lshw -short
```

If hardware details still appear limited, document it as a virtualization limitation (normal in cloud).

---

## 4) ⚠️ Virtual machine does not show “real” physical hardware

### ✅ Problem

Output differs from physical systems (BIOS vendor shows cloud provider, missing device details, etc.).

### 🔎 Likely Cause

Cloud environments expose *virtualized hardware* and abstract the underlying physical system.

### ✅ Fix

Focus on what is available and actionable:

* CPU topology + model
* RAM size
* storage devices (NVMe/EBS)
* NIC (ENA)
* filesystem usage and I/O metrics

---

## 5) ❌ Confusion about memory numbers (Free vs Available)

### ✅ Problem

`free -h` shows large cache/buffers and “free” looks low.

### 🔎 Likely Cause

Linux uses free RAM for caching to improve performance.

### ✅ Fix

Use **available** memory to judge headroom:

* `free -h`
* `/proc/meminfo` → `MemAvailable`

Reminder:

* Buffers/cache are usually reclaimable under memory pressure.

---

## 6) ❌ Device name mismatches (expecting `sda` but seeing `nvme0n1`)

### ✅ Problem

Commands or assumptions expect `sda`, but storage shows `nvme0n1` / `nvme1n1`.

### 🔎 Likely Cause

The system uses NVMe-backed storage. Device names differ by storage type.

### ✅ Fix

List device names:

```bash id="of4oyp"
lsblk
lsblk -f
```

Use the correct device name in analysis (e.g., `nvme0n1`).

---

## 7) ❌ `iostat` not available (if sysstat missing)

### ✅ Problem

Running:

```bash
iostat -x
```

fails with `command not found`.

### 🔎 Likely Cause

`iostat` is provided by the `sysstat` package, which may not be installed.

### ✅ Fix

Install sysstat:

```bash id="ge8pcy"
sudo dnf install -y sysstat
```

Then retry:

```bash id="2e4r9m"
iostat -x 1 3
```

---

## 8) ❌ Network tests fail (ping blocked)

### ✅ Problem

`ping -c 4 8.8.8.8` fails or shows packet loss.

### 🔎 Likely Cause

* ICMP may be restricted by environment policy
* temporary routing/NAT issues
* local firewall rules

### ✅ Fix

Check local interface state:

```bash id="si0ts9"
ip link show
ip addr show
```

Try pinging the gateway or DNS:

```bash id="g1f6fg"
ping -c 4 8.8.8.8
ping -c 4 1.1.1.1
```

If blocked by policy, record the limitation in your report (do not force changes unless allowed).

---

## ✅ Quick Verification Checklist

Use these commands to confirm the lab artifacts exist and key tasks are complete:

### CPU + Memory + Storage basics:

```bash id="i85kfp"
lscpu | head
free -h
lsblk
df -h
```

### Inventory + Network:

```bash id="o3u4th"
sudo lshw -short
ip link show
ip addr show
ping -c 2 8.8.8.8
```

### Script + artifact outputs:

```bash id="k9ag77"
ls -la system_report.sh monitor_resources.sh resource_log.csv baseline_report.txt
head -n 5 resource_log.csv
cat baseline_report.txt
```
