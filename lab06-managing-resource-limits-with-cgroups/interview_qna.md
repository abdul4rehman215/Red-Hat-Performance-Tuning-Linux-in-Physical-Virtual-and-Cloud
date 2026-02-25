# 🎤 Interview Q&A — Lab 06: Managing Resource Limits with cgroups (v2)

## 1) What are Linux cgroups and why are they used?
cgroups (Control Groups) are a Linux kernel feature used to **group processes** and apply **resource controls** (CPU, memory, I/O, pids, etc.). They’re used to prevent resource monopolization, improve stability, and enable multi-tenant workloads—also forming the foundation for containers.

---

## 2) What is cgroups v2 and how is it different from v1?
cgroups v2 uses a **unified hierarchy** (`cgroup2`) with a more consistent design and a single mount point (commonly `/sys/fs/cgroup`). v1 used multiple hierarchies (separate mounts) and controller behavior could differ across them.

In this lab, v2 was verified by:
- mount output showing `cgroup2 on /sys/fs/cgroup`
- systemd indicating `default-hierarchy=unified`

---

## 3) Where are cgroups configured in cgroups v2?
Primarily through files under:
- `/sys/fs/cgroup`

A cgroup is created as a directory (example):
- `/sys/fs/cgroup/lab6_demo/`

---

## 4) How do you check which controllers are available?
Use:
```bash
cat /sys/fs/cgroup/cgroup.controllers
````

In this lab the available controllers included:
`cpuset cpu io memory hugetlb pids rdma misc`

---

## 5) Why do you write `+cpu`, `+memory`, `+io` into `cgroup.subtree_control`?

In cgroups v2, you must **enable controllers** on the *parent* so that child cgroups can use them.
Example used in the lab:

```bash
echo "+cpu" | sudo tee /sys/fs/cgroup/cgroup.subtree_control
echo "+memory" | sudo tee /sys/fs/cgroup/cgroup.subtree_control
echo "+io" | sudo tee /sys/fs/cgroup/cgroup.subtree_control
```

---

## 6) How did you limit CPU usage for processes?

By setting:

* `cpu.weight` for relative priority
* `cpu.max` to cap CPU quota per period

In this lab:

* `cpu.weight = 50`
* `cpu.max = 50000 100000` (≈50% of one CPU core)

---

## 7) How did you verify CPU throttling worked?

Three ways:

1. `top` showed the process near ~50% CPU
2. `cpu.stat` showed throttling counters:

* `nr_throttled`
* `throttled_usec`

3. `watch` confirmed those values increasing under load.

---

## 8) How did you apply memory limits and what is the difference between `memory.max` and `memory.high`?

* `memory.max` is a **hard limit** (can trigger OOM kill if exceeded)
* `memory.high` is a **soft throttle threshold** that pressures the workload before hard limit

In this lab:

* `memory.high = 80MB`
* `memory.max  = 100MB`

---

## 9) How did you verify memory enforcement?

* checked `memory.current`
* checked `memory.events` and observed:

  * `high` increments (soft limit)
  * `max` increments
  * `oom` and `oom_kill` increments

That demonstrated actual memory enforcement under pressure.

---

## 10) How did you limit disk I/O using cgroups v2?

By using `io.max` with the device major:minor ID.
Steps:

1. Find device major:minor for `/`:

```bash
df / | tail -1 | awk '{print $1}' | xargs lsblk -no MAJOR:MINOR
```

2. Apply bandwidth limits:

* read ~10MB/s (`rbps=10485760`)
* write ~5MB/s (`wbps=5242880`)

---

## 11) How did you validate that I/O throttling was effective?

By comparing `dd` speed:

* Without limits: ~GB/s
* With limits: ~5.2 MB/s write and ~10.5 MB/s read

Also verified via:

```bash
cat /sys/fs/cgroup/lab6_demo/io.stat
```

---

## 12) What does `cgroup.procs` do?

`cgroup.procs` contains the list of PIDs in a cgroup.
Writing a PID into it moves the process into that cgroup:

```bash
echo $PID | sudo tee /sys/fs/cgroup/lab6_demo/cgroup.procs
```

---

## 13) How did you make the cgroup configuration persistent?

By creating a **systemd oneshot service** (`lab6-cgroup.service`) that:

* recreates `/sys/fs/cgroup/lab6_demo`
* enables controllers in `cgroup.subtree_control`
* applies CPU/memory defaults

Then:

```bash
sudo systemctl daemon-reload
sudo systemctl enable lab6-cgroup.service
sudo systemctl start lab6-cgroup.service
```

---

## 14) Why is cgroups important for containers (Docker/Podman/Kubernetes)?

Containers rely on cgroups to enforce:

* CPU quotas
* memory limits / OOM handling
* I/O throttling
* PID limits
  This is how platforms prevent “noisy neighbor” workloads and ensure fair resource usage.

---

## 15) What are common mistakes when using cgroups v2 manually?

* forgetting to enable controllers in `cgroup.subtree_control`
* using the wrong device major:minor for `io.max`
* moving a parent process but not the actual worker processes (depending on how workloads fork)
* expecting permission to write under `/sys/fs/cgroup` without `sudo`
