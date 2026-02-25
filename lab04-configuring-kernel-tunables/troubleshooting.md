# 🛠️ Troubleshooting Guide — Lab 04: Configuring Kernel Tunables

> This guide covers common issues when exploring `/proc/sys`, applying sysctl changes, validating persistence, and running memory/network test scripts.

---

## 1) ❌ Permission Denied when changing parameters
### ✅ Problem
Commands like:
```bash
sysctl vm.swappiness=10
echo 10 > /proc/sys/vm/swappiness
````

fail with permission errors.

### 🔎 Likely Cause

Kernel parameter modification requires root privileges.

### ✅ Fix

1. Confirm sudo access:

```bash
sudo -l
```

2. Apply changes with sudo:

```bash id="u0wfc4"
sudo sysctl vm.swappiness=10
```

3. If writing to `/proc/sys` directly:

```bash id="dr6bq6"
echo 10 | sudo tee /proc/sys/vm/swappiness
```

---

## 2) ❌ Parameter Not Found

### ✅ Problem

`sysctl` returns “cannot stat /proc/sys/...” or the file path doesn’t exist.

### 🔎 Likely Cause

* Parameter name differs by kernel version/distro
* The feature is not enabled in the kernel build

### ✅ Fix

Search for the parameter in `/proc/sys`:

```bash id="xm1f9j"
find /proc/sys -name "*swappiness*" 2>/dev/null
```

List available parameters in a category:

```bash id="eh5bse"
sysctl -a | grep '^vm\.' | head -20
```

---

## 3) ❌ Changes revert after reboot (not persistent)

### ✅ Problem

Tuning works during the session but resets after restart.

### 🔎 Likely Cause

Runtime sysctl changes are not persistent unless written to config files.

### ✅ Fix

1. Create a sysctl.d file (recommended approach used in lab):

* `/etc/sysctl.d/99-performance-tuning.conf`

2. Apply it immediately:

```bash id="z2uz6k"
sudo sysctl -p /etc/sysctl.d/99-performance-tuning.conf
```

3. Confirm it loads in boot sequence:

```bash id="0w2dce"
sudo sysctl --system
```

---

## 4) ❌ `sysctl -p` errors / config not applying cleanly

### ✅ Problem

Applying the config prints errors or doesn’t apply all keys.

### 🔎 Likely Cause

* syntax errors in the `.conf` file
* invalid parameter names
* permission issues

### ✅ Fix

1. Apply and watch output:

```bash id="n2t9kw"
sudo sysctl -p /etc/sysctl.d/99-performance-tuning.conf
```

2. Check for errors:

```bash id="p5mz3x"
sudo sysctl --system 2>&1 | grep -i error
```

3. Validate file permissions:

```bash id="8y80e5"
ls -la /etc/sysctl.d/99-performance-tuning.conf
```

---

## 5) ❌ Network test fails: `nc: command not found`

### ✅ Problem

Running `network_test.sh` shows:
`nc: command not found`

### 🔎 Likely Cause

Netcat isn’t installed by default on minimal images.

### ✅ Fix (RHEL)

Install `nmap-ncat`:

```bash id="1hd0he"
sudo dnf install -y nmap-ncat
```

Re-run test:

```bash id="hj2bv8"
chmod +x /tmp/network_test.sh
/tmp/network_test.sh
```

---

## 6) ⚠️ System instability or unexpected behavior after tuning

### ✅ Problem

After tuning, system responsiveness changes unexpectedly.

### 🔎 Likely Cause

Kernel tuning can affect latency, caching, writeback behavior, and network queues. Aggressive values may not suit the workload.

### ✅ Fix

1. Use rollback script (created in lab):

```bash id="q3v5jm"
/tmp/rollback_tuning.sh
```

2. Or manually restore key defaults:

```bash id="tadf6p"
sudo sysctl vm.swappiness=60
sudo sysctl vm.dirty_ratio=20
sudo sysctl vm.dirty_background_ratio=10
sudo sysctl vm.vfs_cache_pressure=100
sudo sysctl net.core.somaxconn=128
sudo sysctl net.core.netdev_max_backlog=1000
```

3. If you want rollback to persist across reboot:

* remove or rename the tuning file:

  * `/etc/sysctl.d/99-performance-tuning.conf`

---

## 7) ✅ Validation script shows mismatches

### ✅ Problem

`validate_config.sh` reports parameters do not match expected values.

### 🔎 Likely Cause

* some values were changed manually after applying config
* config file wasn’t loaded (or got overridden by another sysctl file)

### ✅ Fix

1. Re-apply tuning:

```bash id="j0g52m"
sudo sysctl -p /etc/sysctl.d/99-performance-tuning.conf
```

2. Check load order:

```bash id="5c0e4p"
sudo sysctl --system
```

3. Re-run validation:

```bash id="p70m2k"
/tmp/validate_config.sh
```

---

## 8) 🔐 Security note: tuning can impact security posture

### ✅ Problem

Some tuning may weaken defenses if done incorrectly (e.g., DoS hardening).

### ✅ Fix

Verify key safety-related settings remain enabled (examples used in lab):

```bash id="g40ev7"
sysctl net.ipv4.tcp_syncookies
sysctl net.ipv4.icmp_echo_ignore_broadcasts
```

If you’re tuning production, document changes and evaluate security impacts before rollout.

---

## ✅ Quick Verification Checklist

Use these commands to confirm lab completion:

### Confirm tuned values:

```bash id="5ds6ib"
sysctl vm.swappiness vm.dirty_ratio vm.dirty_background_ratio vm.vfs_cache_pressure
sysctl net.core.rmem_max net.core.wmem_max net.core.somaxconn net.core.netdev_max_backlog
sysctl net.ipv4.tcp_rmem net.ipv4.tcp_wmem
```

### Confirm persistence:

```bash id="7y2y11"
ls -la /etc/sysctl.d/99-performance-tuning.conf
sudo sysctl --system | tail -n 10
```

### Run validation + analysis:

```bash id="5f89e9"
/tmp/validate_config.sh
/tmp/performance_analysis.sh
```
