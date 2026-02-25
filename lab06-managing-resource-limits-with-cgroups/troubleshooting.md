# 🛠️ Troubleshooting Guide — Lab 06: Managing Resource Limits with cgroups (v2)

> This guide focuses on real issues you can hit when managing **cgroups v2** manually using `/sys/fs/cgroup`.

---

## 1) ❌ `mount | grep cgroup` doesn’t show `cgroup2`
### Symptoms
- No output for `cgroup2`
- `/sys/fs/cgroup` exists but looks different than expected

### Likely Causes
- System booted in legacy mode (cgroups v1)
- systemd not using unified hierarchy

### Fix
1) Check systemd cgroup mode:
```bash
systemctl --version | grep -i hierarchy
````

2. On systemd-based systems, ensure unified hierarchy is enabled (varies by distro).
   On RHEL9/CentOS9, unified is default and usually already enabled.

---

## 2) ❌ “Permission denied” writing to `/sys/fs/cgroup/...`

### Symptoms

```bash
echo "50000 100000" > /sys/fs/cgroup/lab6_demo/cpu.max
# Permission denied
```

### Cause

cgroup filesystem needs elevated privileges.

### Fix

Use `sudo tee`:

```bash
echo "50000 100000" | sudo tee /sys/fs/cgroup/lab6_demo/cpu.max
```

---

## 3) ❌ Controllers not available in child cgroup

### Symptoms

* You create `/sys/fs/cgroup/lab6_demo`
* But resource files don’t behave as expected, or child cgroup doesn’t inherit enabled controllers

### Cause

In cgroups v2, controllers must be enabled in the **parent** using `cgroup.subtree_control`.

### Fix

Enable controllers in parent:

```bash
echo "+cpu +memory +io" | sudo tee /sys/fs/cgroup/cgroup.subtree_control
```

Confirm:

```bash
cat /sys/fs/cgroup/cgroup.subtree_control
```

---

## 4) ❌ CPU cap doesn’t seem to apply (process still uses ~100%)

### Likely Causes

* PID not actually placed into the cgroup
* workload forks and the worker PID is outside the cgroup
* CPU cap value not correctly set

### Fix

1. Confirm PID is in the cgroup:

```bash
cat /sys/fs/cgroup/lab6_demo/cgroup.procs
```

2. Re-add PID:

```bash
echo <PID> | sudo tee /sys/fs/cgroup/lab6_demo/cgroup.procs
```

3. Verify cap:

```bash
cat /sys/fs/cgroup/lab6_demo/cpu.max
```

4. Check throttling evidence:

```bash
cat /sys/fs/cgroup/lab6_demo/cpu.stat
```

Look for:

* `nr_throttled`
* `throttled_usec`

---

## 5) ❌ Memory test doesn’t fail / no OOM events appear

### Likely Causes

* process not placed into the cgroup
* memory limit too high for your allocation
* python allocation pattern not hitting limit

### Fix

1. Confirm memory limits:

```bash
cat /sys/fs/cgroup/lab6_demo/memory.high
cat /sys/fs/cgroup/lab6_demo/memory.max
```

2. Confirm events:

```bash
cat /sys/fs/cgroup/lab6_demo/memory.events
```

3. Confirm PID placement:

```bash
cat /sys/fs/cgroup/lab6_demo/cgroup.procs
```

4. Increase allocation attempt (or lower limits) carefully.

---

## 6) ❌ `io.max` has no visible impact

### Likely Causes

* wrong device major:minor selected
* filesystem is not on the device you limited
* workload is cached (reads served from page cache)

### Fix

1. Confirm root device major:minor exactly:

```bash
df / | tail -1 | awk '{print $1}' | xargs lsblk -no MAJOR:MINOR
```

2. Confirm `io.max` value:

```bash
cat /sys/fs/cgroup/lab6_demo/io.max
```

3. Ensure the I/O-heavy process is in the cgroup:

```bash
cat /sys/fs/cgroup/lab6_demo/cgroup.procs
```

4. For read tests, caching can hide throttling; write tests generally show throttling more clearly.

---

## 7) ⚠️ `watch` commands break due to quoting

### Symptoms

* `watch` fails with parsing errors

### Fix

Wrap complex commands in quotes:

```bash
watch -n 1 "echo 'Current:'; cat /sys/fs/cgroup/lab6_demo/memory.current; echo 'Events:'; cat /sys/fs/cgroup/lab6_demo/memory.events"
```

---

## 8) ❌ systemd unit runs but cgroup isn’t configured as expected

### Likely Causes

* incorrect quoting / escaping in `ExecStart=`
* unit started before the cgroup mount is fully ready (rare in normal multi-user flow)
* unit file not reloaded after edits

### Fix

1. Reload systemd:

```bash
sudo systemctl daemon-reload
```

2. Restart service:

```bash
sudo systemctl restart lab6-cgroup.service
```

3. Check status + logs:

```bash
sudo systemctl status lab6-cgroup.service --no-pager
journalctl -u lab6-cgroup.service --no-pager -n 50
```

4. Validate settings:

```bash
cat /sys/fs/cgroup/lab6_demo/cpu.max
cat /sys/fs/cgroup/lab6_demo/memory.max
```

---

## 9) ✅ Quick Validation Commands (End-of-Lab)

### Check cgroups v2

```bash
mount | grep cgroup
systemctl --version | grep -i hierarchy
```

### Confirm controllers + limits

```bash
cat /sys/fs/cgroup/cgroup.controllers
cat /sys/fs/cgroup/cgroup.subtree_control

cat /sys/fs/cgroup/lab6_demo/cpu.max
cat /sys/fs/cgroup/lab6_demo/memory.max
cat /sys/fs/cgroup/lab6_demo/io.max
```

### Confirm enforcement signals

```bash
cat /sys/fs/cgroup/lab6_demo/cpu.stat
cat /sys/fs/cgroup/lab6_demo/memory.events
cat /sys/fs/cgroup/lab6_demo/io.stat
```

---

## 10) Cleanup Problems: “Device or resource busy” when removing cgroup directories

### Cause

You can’t remove cgroup directories while processes are still inside them.

### Fix

1. Ensure no PIDs remain:

```bash
cat /sys/fs/cgroup/lab6_demo/cgroup.procs
```

2. Kill remaining processes:

```bash
sudo pkill -f "cpu_stress|memory_stress|io_stress|web_server_sim" 2>/dev/null || true
```

3. Retry removal:

```bash
sudo rmdir /sys/fs/cgroup/lab6_demo 2>/dev/null || true
```
