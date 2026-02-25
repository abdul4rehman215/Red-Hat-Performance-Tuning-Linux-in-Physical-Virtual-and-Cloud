# 🛠️ Troubleshooting Guide - Lab 9: Memory Utilization Tuning

> This file documents the **real issues encountered in the lab** and the exact fixes used.

---

## Issue 1: Permission denied when modifying `/proc/sys/*` parameters

### Symptom
- Cannot change `vm.swappiness` or other kernel parameters directly.

### Fix
Use `sudo` with `sysctl`, or use `tee` for `/proc/sys` writes:

```bash
sudo sysctl vm.swappiness=10
echo 10 | sudo tee /proc/sys/vm/swappiness
````

✅ Verified in lab:

```bash
sudo -l
sudo sysctl vm.swappiness=10
echo 10 | sudo tee /proc/sys/vm/swappiness
```

---

## Issue 2: Changes don’t persist after reboot

### Symptom

* After restart, `vm.swappiness` resets to default (commonly 60).

### Fix (Persistent config)

Append setting to `/etc/sysctl.conf` and reload:

```bash
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
grep swappiness /etc/sysctl.conf
```

⚠️ Lab note (realistic mistake):
If you append multiple times, you can create duplicates:

Example from lab:

```bash
grep swappiness /etc/sysctl.conf
vm.swappiness=10
vm.swappiness=10
```

✅ Best practice (recommended):
Edit `/etc/sysctl.conf` and keep **only one** final line, or better:

* Put tuning in `/etc/sysctl.d/99-memory-tuning.conf`

---

## Issue 3: System becomes slow / unresponsive during memory stress tests

### Symptom

* VM becomes very slow or appears frozen when stressing memory heavily.

### Fix (reduce pressure)

Use smaller workload:

```bash
stress-ng --vm 1 --vm-bytes 25% --timeout 30s
```

Then check system health:

```bash
free -h
vmstat 1 3
watch -n 2 'free -h'
```

✅ Verified in lab:

```bash
stress-ng --vm 1 --vm-bytes 25% --timeout 30s
free -h && vmstat 1 3
watch -n 2 'free -h'
```

---

## Issue 4: Swap not available (common in cloud lab VMs)

### Symptom

* `swapon --show` shows nothing
* `/proc/swaps` shows no active swap
* `free -h` shows swap = `0B`

### Fix (create a swapfile for testing)

```bash
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
free -h
```

✅ Verified in lab:

```bash
swapon --show
cat /proc/swaps
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
free -h
```

---

## Common “gotchas” captured from the lab

### 1) `sudo echo 3 > /proc/sys/vm/drop_caches` may fail

Because the `>` redirect runs in your current shell (not under sudo).

✅ Correct way:

```bash
echo 3 | sudo tee /proc/sys/vm/drop_caches
```

### 2) `vmstat -s` may look inconsistent with `swapon`

Lab note: some fields can confuse beginners (swap totals may appear odd depending on kernel reporting).
Trust these for actual swap:

* `swapon --show`
* `cat /proc/swaps`
* `free -h`

---

## Quick Debug Checklist

Run these anytime something feels off:

```bash
free -h
vmstat 1 5
cat /proc/sys/vm/swappiness
sysctl vm.swappiness vm.vfs_cache_pressure vm.dirty_ratio vm.dirty_background_ratio
swapon --show
cat /proc/swaps
```

---

