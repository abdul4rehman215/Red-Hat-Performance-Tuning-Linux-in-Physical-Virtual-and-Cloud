# 🧪 Lab 06: Managing Resource Limits with cgroups (cgroups v2)

## 🧾 Lab Summary
In this lab, I worked with **Linux cgroups v2** (unified hierarchy) to enforce **resource limits** on real processes. I created custom cgroups, enabled controllers, and applied limits for:

- **CPU** (weight + quota via `cpu.max`)
- **Memory** (`memory.max` + `memory.high`)
- **Disk I/O** throttling (`io.max` using device major:minor)

I verified limits by running CPU, memory, and I/O stress workloads and monitoring live cgroup statistics such as:
- `cpu.stat` throttling counters
- `memory.current`, `memory.events`, and `memory.stat`
- `io.stat` read/write byte counters

To make the setup repeatable, I also created a **systemd oneshot service** that recreates the cgroup and re-applies limits on boot. Finally, I tested a practical scenario by running a small simulated **web server** under cgroup limits.

---

## 🎯 Objectives
By the end of this lab, I was able to:

- Understand the fundamentals of **cgroups v2** and why resource controls matter
- Create and configure cgroups to limit **CPU**, **memory**, and **I/O**
- Attach processes to cgroups and observe enforcement in real workloads
- Monitor usage using cgroup files like `cpu.stat`, `memory.events`, and `io.stat`
- Fine-tune limits based on observed behavior and performance metrics
- Implement practical resource-management scenarios in a production-style workflow

---

## ✅ Prerequisites
- Linux CLI + basic admin knowledge
- Process management fundamentals (PIDs, background jobs, `kill`)
- Understanding of system resources (CPU, RAM, disk I/O)
- Root/sudo access
- Familiarity navigating filesystem paths (especially `/sys`)

---

## 🖥️ Lab Environment
- **OS:** CentOS Stream 9 / RHEL 9-style system  
- **cgroups:** v2 (unified hierarchy)
- **Mountpoint:** `/sys/fs/cgroup`
- **systemd:** `252` (`default-hierarchy=unified`)
- **Monitoring:** `top`, `watch`, cgroup stat files under `/sys/fs/cgroup`

✅ Note: This lab explicitly used **cgroups v2** (`cgroup2 on /sys/fs/cgroup`).

---

## 📁 Repository Structure
```text
lab06-managing-resource-limits-with-cgroups/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
└── scripts/
    ├── cpu_stress.sh
    ├── memory_stress.py
    ├── io_stress.sh
    ├── cgroup_monitor.sh
    ├── mixed_workload.sh
    ├── cgroup_troubleshoot.sh
    ├── performance_comparison.sh
    ├── web_server_sim.py
    └── lab6-cgroup.service
````

> **Note on realism:** Some scripts were created under `/tmp` and `/etc/systemd/system` during the lab.
> For GitHub, I keep them inside `scripts/` as tracked artifacts.

---

## 🧩 Lab Tasks Overview (What I Did)

### ✅ Task 1: Verify cgroups v2 + explore hierarchy

* Verified `cgroup2` mounted at `/sys/fs/cgroup`
* Checked controllers available: `cpuset cpu io memory hugetlb pids rdma misc`
* Confirmed systemd uses unified hierarchy (`default-hierarchy=unified`)
* Created a custom cgroup: `/sys/fs/cgroup/lab6_demo`

---

### ✅ Task 2: Configure CPU limits

* Enabled CPU controller for subtree management
* Set:

  * `cpu.weight = 50` (relative priority)
  * `cpu.max = 50000 100000` (50% of one CPU period)
* Ran CPU stress loop and moved PID into the cgroup
* Confirmed enforcement via:

  * `top` (~50% CPU observed)
  * `cpu.stat` showing throttling (`nr_throttled`, `throttled_usec`)

---

### ✅ Task 3: Configure Memory limits

* Enabled memory controller
* Set:

  * `memory.max = 104857600` (100MB hard limit)
  * `memory.high = 83886080` (80MB soft throttle point)
* Ran Python memory allocation test (up to 200MB attempt)
* Observed memory enforcement via:

  * `memory.current`
  * `memory.events` (`high`, `max`, `oom`, `oom_kill`)

---

### ✅ Task 4: Configure I/O limits

* Enabled I/O controller
* Determined device major:minor for root filesystem (example: `259:1`)
* Applied throttles:

  * `rbps=10485760` (~10MB/s read)
  * `wbps=5242880` (~5MB/s write)
* Verified limits by comparing dd speeds:

  * Without limits: ~GB/s
  * With limits: ~5.2 MB/s write, ~10.5 MB/s read
* Monitored with `io.stat`

---

### ✅ Task 5: Advanced monitoring + fine-tuning

* Built a full-screen cgroup monitor (`cgroup_monitor.sh`)
* Ran a mixed workload (CPU+memory+I/O) and attached it to the cgroup
* Fine-tuned limits:

  * CPU increased to 75% (`cpu.max 75000 100000`)
  * Memory increased to 150MB (`memory.max 157286400`)
* Stopped monitor/workload after observation

---

### ✅ Task 5.3: Make configuration persistent (systemd)

* Created `lab6-cgroup.service` (oneshot + `RemainAfterExit`)
* Service recreates cgroup + re-applies CPU/memory/I/O controller setup and limits
* Enabled and started service, verified it is active (exited) successfully

---

### ✅ Task 6: Practical scenario + troubleshooting

* Web server simulation under cgroup limits:

  * CPU limit `30000 100000` (~30%)
  * Memory limit `52428800` (50MB)
  * Generated load with `curl` loops
* Created cgroup troubleshooting helper script
* Created performance comparison script (with vs without cgroup limits)
* Completed full cleanup (processes, temp files, cgroups, systemd unit)

---

## ✅ Verification Checklist

You can consider this lab complete when:

* `mount | grep cgroup` shows `cgroup2` mounted
* `lab6_demo` cgroup exists and has controller files
* CPU limits applied in `cpu.max` and reflect throttling in `cpu.stat`
* Memory limits applied in `memory.max` and show events in `memory.events`
* I/O limits applied in `io.max` and affect `dd` throughput
* systemd unit exists and runs successfully (optional persistence step)

---

## 🧠 What I Learned

* cgroups v2 provides unified, filesystem-based resource control for processes
* CPU quotas (`cpu.max`) enforce predictable throttling and show it clearly in `cpu.stat`
* Memory limits can trigger `oom_kill` events when processes exceed `memory.max`
* I/O throttling (`io.max`) can drastically change disk throughput and enforce fairness
* cgroups are the foundation for container resource enforcement (Kubernetes, Podman, Docker)
* systemd is a practical way to make cgroup rules repeatable across reboots

---

## ✅ Conclusion

This lab demonstrated end-to-end resource control using **cgroups v2**: creating cgroups, enabling controllers, applying CPU/memory/I/O constraints, validating behavior under load, and implementing persistence through systemd. The workflow closely matches real-world operations for multi-tenant Linux systems and container-based environments.
