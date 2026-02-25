# 🛠️ Troubleshooting Guide — Lab 05: Applying Tuned Profiles for Optimization

> This document covers the most common issues when managing tuned profiles and validating performance changes on RHEL/CentOS systems.

---

## 1) ❌ `tuned-adm` command not found
### ✅ Problem
Running `tuned-adm` fails:
```bash
bash: tuned-adm: command not found
````

### 🔎 Likely Cause

`tuned` / `tuned-utils` not installed.

### ✅ Fix (RHEL/CentOS)

```bash
sudo dnf install -y tuned tuned-utils
sudo systemctl enable --now tuned
```

---

## 2) ❌ tuned service not running / inactive

### ✅ Problem

`tuned-adm active` works but profiles don't apply correctly, or service shows inactive.

### 🔎 Likely Cause

`tuned.service` not enabled/started.

### ✅ Fix

```bash
sudo systemctl enable --now tuned
systemctl status tuned --no-pager
```

---

## 3) ❌ Profile apply works but verification fails (`tuned-adm verify`)

### ✅ Problem

`tuned-adm verify` shows failure or errors.

### 🔎 Likely Causes

* profile conflicts or partial application
* custom profile syntax errors
* permissions issues
* missing kernel features on VM images

### ✅ Fix

1. Reapply profile:

```bash
sudo tuned-adm profile <profile>
tuned-adm verify
```

2. Review tuned logs:

```bash
journalctl -u tuned --no-pager -n 50
```

3. Confirm active profile matches expectation:

```bash
tuned-adm active
```

---

## 4) ❌ `cat /sys/block/sda/queue/scheduler` fails

### ✅ Problem

The lab command errors:

```bash
cat: /sys/block/sda/queue/scheduler: No such file or directory
```

### 🔎 Likely Cause

The VM uses NVMe disks (`/dev/nvme0n1`) instead of `sda`.

### ✅ Fix

Identify devices:

```bash
lsblk
```

Check the correct scheduler path:

```bash
cat /sys/block/nvme0n1/queue/scheduler
```

---

## 5) ⚠️ CPU governor doesn’t match what you expected

### ✅ Problem

After applying a profile, governor seems different than the profile config suggests.

### 🔎 Likely Causes

* cpufreq interface may be limited or abstracted in some virtual environments
* tuned may apply closest valid setting supported by the platform
* profile inheritance affects effective config

### ✅ Fix

1. Confirm governor:

```bash
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
```

2. Confirm active profile:

```bash
tuned-adm active
```

3. Inspect profile `tuned.conf` + inheritance:

```bash
cat /usr/lib/tuned/<profile>/tuned.conf
```

---

## 6) ❌ Custom profile not found when applying

### ✅ Problem

```bash
sudo tuned-adm profile custom-lab-profile
```

fails because profile isn’t recognized.

### 🔎 Likely Cause

Profile directory or `tuned.conf` missing/misplaced.

### ✅ Fix

1. Ensure correct directory exists:

```bash
sudo ls -la /etc/tuned/
sudo ls -la /etc/tuned/custom-lab-profile/
```

2. Ensure config exists:

```bash
sudo cat /etc/tuned/custom-lab-profile/tuned.conf
```

3. Reapply:

```bash
sudo tuned-adm profile custom-lab-profile
tuned-adm verify
```

---

## 7) ⚠️ tuned recommends `virtual-guest` but you prefer another profile

### ✅ Problem

`tuned-adm recommend` says `virtual-guest`, but you want e.g. `throughput-performance`.

### 🔎 Guidance

Recommendation is environment-based and generally safe, but workload needs may require a different profile.

### ✅ Best Practice Fix

* Test with baseline + stress tests
* compare results before committing a change in production

```bash
tuned-adm recommend
sudo tuned-adm profile throughput-performance
tuned-adm verify
```

---

## 8) ❌ Monitoring scripts show “No results file found”

### ✅ Problem

`compare_profiles.sh` prints missing result files.

### 🔎 Likely Cause

Stress test wasn’t run for that profile or output file names differ.

### ✅ Fix

1. Confirm files exist:

```bash
ls -la ~/stress_results_*.log
```

2. Re-run stress test for that profile:

```bash
~/stress_test.sh "<profile-name>"
```

3. Ensure naming consistency in scripts:

* `~/stress_results_${PROFILE_NAME}.log`

---

## 9) ⚠️ Stress test impacts system responsiveness

### ✅ Problem

Stress tests can cause high CPU usage and temporary sluggishness.

### 🔎 Likely Cause

Designed behavior — CPU busy loop + repeated `dd` writes.

### ✅ Fix

* Wait for `timeout` to end (30s), or stop early by killing processes:

```bash
pkill -f "while true; do :; done"
pkill -f "dd if=/dev/zero"
```

---

## 10) ✅ Quick Verification Checklist

### tuned health + profile

```bash
systemctl status tuned --no-pager
tuned-adm active
tuned-adm verify
tuned-adm list
tuned-adm recommend
```

### confirm what changed

```bash
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
lsblk
cat /sys/block/nvme0n1/queue/scheduler
sysctl vm.swappiness
sysctl kernel.sched_min_granularity_ns
sysctl net.core.rmem_max
```

### verify scripts + reports

```bash
ls -la ~/tuned_performance_data/
ls -la ~/stress_results_*.log
cat ~/tuned_performance_report.txt
```

