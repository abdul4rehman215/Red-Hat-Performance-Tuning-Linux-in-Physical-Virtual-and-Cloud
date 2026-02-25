## 🛠️ Troubleshooting Guide- Lab 08:  Tuning CPU Utilization 

---

## ✅ Quick Checklist (Before Troubleshooting)

Run these first to confirm basic system health:

```bash
uptime
free -h
df -h
lscpu | head
nproc
```

---

## 1) `cat /sys/block/sda/queue/scheduler: No such file or directory`

### ✅ Cause

Your cloud VM uses **NVMe**, so the disk is `nvme0n1`, not `sda`.

### ✅ Fix

Find correct disk:

```bash
lsblk
```

Then use:

```bash
cat /sys/block/nvme0n1/queue/scheduler
```

---

## 2) `sysctl: permission denied` or kernel parameter won’t change

### ✅ Cause

Kernel tunables require root privileges.

### ✅ Fix

Use sudo:

```bash
sudo sysctl kernel.sched_min_granularity_ns=1000000
```

Verify:

```bash
sysctl kernel.sched_min_granularity_ns
```

If you still get blocked in certain environments, check:

```bash
sudo -l
id
```

---

## 3) Sysctl changes disappear after reboot

### ✅ Cause

You applied changes temporarily, but did not persist them.

### ✅ Fix (Persistent)

Append to `/etc/sysctl.conf` (as you did in this lab):

```bash
sudo nano /etc/sysctl.conf
```

Add:

```conf
# CPU Scheduler Optimizations
kernel.sched_min_granularity_ns=1000000
kernel.sched_wakeup_granularity_ns=2000000
kernel.sched_migration_cost_ns=250000
kernel.sched_latency_ns=6000000
```

Reload without reboot:

```bash
sudo sysctl -p
```

---

## 4) `taskset` affinity “doesn’t work” / process still appears across CPUs

### ✅ Causes

* You pinned the **parent shell**, not the actual process PID
* The workload spawns threads/processes (especially Python)
* You didn’t verify the PID you pinned

### ✅ Fix

Pin at launch:

```bash
taskset -c 0,1 python3 cpu_intensive.py 60 &
PID=$!
taskset -p $PID
```

Or pin an already running process:

```bash
taskset -cp 0,1 <PID>
taskset -p <PID>
```

If it’s multi-threaded, check threads:

```bash
ps -eLf | grep <PID>
```

---

## 5) `numactl: command not found`

### ✅ Cause

Package not installed (common in minimal cloud images)

### ✅ Fix

```bash
sudo apt update
sudo apt install -y numactl
numactl --hardware
```

---

## 6) `cpufreq` governor paths missing (cloud VM limitation)

Example error:

```bash
tee: /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor: No such file or directory
```

### ✅ Cause

Many cloud VMs do **not expose CPU frequency scaling** to guests.

### ✅ Fix / Workaround

* Focus tuning on:

  * scheduler sysctl tunables
  * CPU affinity
  * workload distribution
* Use monitoring to validate instead:

```bash
mpstat -P ALL 1 5
vmstat 1 5
top
```

---

## 7) `sudo echo 3 > /proc/sys/vm/drop_caches` → Permission denied

### ✅ Cause

Redirection (`>`) happens in your shell, not in sudo context.

### ✅ Fix

Use tee:

```bash
echo 3 | sudo tee /proc/sys/vm/drop_caches
```

---

## 8) High context switching (`cs`) or unstable performance results

### ✅ Causes

* Too many runnable tasks competing
* Incorrect affinity (oversubscribed cores)
* Background services doing work
* VM scheduling noise

### ✅ Fixes

Measure context switching:

```bash
vmstat 1 10
pidstat -w 1 5
```

Reduce contention:

* Avoid pinning 4 heavy threads on 2 cores unless testing oversubscription
* Use realistic affinity mapping (e.g., 2 tasks on cores 0,1 and 2,3)

Run tests multiple times and compare averages:

```bash
for i in {1..3}; do ./cpu_stress_test.sh; done
```

---

## 9) Tools missing: `mpstat`, `iostat`, `pidstat`, `stress-ng`

### ✅ Cause

These come from specific packages.

### ✅ Fix (Ubuntu 20.04+)

```bash
sudo apt update
sudo apt install -y sysstat stress-ng htop
```

Verify:

```bash
which mpstat iostat pidstat stress-ng htop
```

---

## 10) cgroup path errors (v1 vs v2 mismatch)

Example:

```bash
sudo mkdir -p /sys/fs/cgroup/cpuset/myapp
mkdir: cannot create directory ‘/sys/fs/cgroup/cpuset’: No such file or directory
```

### ✅ Cause

System uses **cgroups v2**, so v1 controller directories like `cpuset/` may not exist.

### ✅ Fix

Check cgroup version:

```bash
mount | grep cgroup
```

If it shows `cgroup2`, use v2 layout and configure via:

* `/sys/fs/cgroup/<group>/`
* systemd units / slices (preferred in production)

---

## ✅ Final Validation Commands

Run these at the end to confirm Lab 08 results are sane:

```bash
sysctl kernel.sched_min_granularity_ns
sysctl kernel.sched_wakeup_granularity_ns
sysctl kernel.sched_migration_cost_ns
sysctl kernel.sched_latency_ns

uptime
vmstat 1 3
mpstat -P ALL 1 1
```

