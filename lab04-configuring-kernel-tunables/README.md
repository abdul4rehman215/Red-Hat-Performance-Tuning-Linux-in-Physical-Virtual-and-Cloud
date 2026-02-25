# 🧪 Lab 04: Configuring Kernel Tunables

## 🧾 Lab Summary
In this lab, I explored Linux **kernel tunables** via the `/proc/sys` interface and used `sysctl` to **inspect, modify, and persist** performance-related kernel parameters. I tuned **memory management** settings (swappiness, dirty ratios, VFS cache pressure) and **network performance** settings (socket buffers, TCP buffers, backlog queues).  

To make the work safe and repeatable, I built:
- baseline monitoring scripts (memory + network)
- stress/verification tests (memory allocation + local throughput test)
- a persistent configuration file under `/etc/sysctl.d/`
- a validation script to confirm tuning is applied correctly
- an analysis script for post-change review
- a rollback script for safe restoration of defaults

---

## 🎯 Objectives
By the end of this lab, I was able to:

- Understand why kernel tunables matter for system optimization
- Explore the `/proc/sys` hierarchy and identify key tuning domains
- Use `sysctl` to view and change kernel parameters
- Tune memory-management kernel parameters for improved behavior under load
- Tune network-related kernel parameters for better throughput and queue handling
- Make kernel parameter changes persistent across reboots
- Validate impact and correctness using monitoring + test scripts
- Apply best practices and troubleshooting approaches for production-style tuning

---

## ✅ Prerequisites
- Linux administration basics
- Comfortable with CLI + editors (nano/vim)
- Networking fundamentals (TCP/IP, buffers, queues)
- Memory management basics (swap, dirty pages, caching)
- sudo/root access
- Familiarity with monitoring tools (`top`, `free`, `ss`, etc.)

---

## 🖥️ Lab Environment
**Environment:** Cloud-based Linux lab VM  
**OS Family:** CentOS/RHEL 8/9 or Ubuntu 20.04 LTS (lab supports multiple distros)  
**Privileges:** sudo/root access available  
**Tools Used:** `sysctl`, `/proc/sys/*`, `free`, `swapon`, `ss`, `iostat`, `dd`, `tee`, `find`, `uptime`

> Note: Hostname observed during troubleshooting section: `ip-172-31-10-248` (sudo validation output).  
> Kernel tuning steps were executed within the same lab workflow, but hostnames can vary across lab sessions.

---

## 📁 Repository Structure
```text
lab04-configuring-kernel-tunables/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
└── scripts/
    ├── memory_monitor.sh
    ├── memory_test.sh
    ├── network_monitor.sh
    ├── network_test.sh
    ├── validate_config.sh
    ├── performance_analysis.sh
    ├── rollback_tuning.sh
    └── continuous_monitor.sh
````

---

## 🧩 Lab Tasks Overview (What I Did)

### ✅ Task 1: Understanding Kernel Tunables

* Navigated to `/proc/sys` and explored major tuning namespaces:

  * `vm/` (virtual memory)
  * `net/` (network stack)
  * `kernel/` (core kernel behavior)
* Used `sysctl -a` to inspect live kernel parameter values.
* Queried specific parameter groups (`sysctl vm.*`) and individual values (`sysctl vm.swappiness`).

---

### ✅ Task 2: Memory Management Kernel Parameters

#### Subtask 2.1: Review Current Memory Settings

* Captured current memory state using `free -h`
* Checked current values for:

  * `vm.swappiness`
  * `vm.dirty_ratio`
  * `vm.dirty_background_ratio`
  * `vm.dirty_writeback_centisecs`

#### Subtask 2.2: Baseline Monitoring Script

Created `memory_monitor.sh` to collect:

* memory usage (`free -h`)
* swap status (`swapon --show`)
* key VM parameters (`sysctl -n ...`)
* memory pressure (`/proc/pressure/memory` if available)

#### Subtask 2.3–2.6: Apply Memory Tuning + Validate

Tuned the following:

* `vm.swappiness`: **60 → 10**
* `vm.dirty_ratio`: **20 → 15**
* `vm.dirty_background_ratio`: **10 → 5**
* `vm.vfs_cache_pressure`: **100 → 150**
* (writeback interval remained `500` centisecs)

Validated results by re-running `memory_monitor.sh` and running `memory_test.sh` (100MB × 5 allocations).

---

### ✅ Task 3: Network Kernel Parameters

#### Subtask 3.1: Review Network Settings

Captured defaults for:

* `net.core.rmem_max`, `net.core.wmem_max`
* `net.core.rmem_default`, `net.core.wmem_default`
* `net.ipv4.tcp_rmem`, `net.ipv4.tcp_wmem`
* `net.ipv4.tcp_congestion_control`
* `net.core.netdev_max_backlog`

#### Subtask 3.2: Baseline Network Monitoring Script

Created `network_monitor.sh` to print:

* buffer settings
* TCP buffer settings
* queue settings
* a snapshot of listening ports (`ss -tuln`)

#### Subtask 3.3–3.6: Apply Network Tuning + Test

Applied tuning:

* `net.core.rmem_max`: **212992 → 16777216**
* `net.core.wmem_max`: **212992 → 16777216**
* `net.core.rmem_default`: **212992 → 262144**
* `net.core.wmem_default`: **212992 → 262144**
* `net.ipv4.tcp_rmem`: **4096 131072 6291456 → 4096 87380 16777216**
* `net.ipv4.tcp_wmem`: **4096 16384 4194304 → 4096 65536 16777216**
* `net.core.netdev_max_backlog`: **1000 → 5000**
* `net.core.somaxconn`: **128 → 1024**
* `net.ipv4.tcp_window_scaling`: **enabled (1)**

Created a local throughput test (`network_test.sh`) using `nc`.
Initially `nc` was missing; installed `nmap-ncat` and re-ran successfully.

---

### ✅ Task 4: Making Kernel Parameter Changes Persistent

Temporary `sysctl` changes do not survive reboot, so I persisted tuning in:

* **`/etc/sysctl.d/99-performance-tuning.conf`**

Applied config without reboot using:

* `sysctl -p /etc/sysctl.d/99-performance-tuning.conf`
* validated load order via `sysctl --system`

---

### ✅ Task 5: Advanced Tuning & Operational Safety

#### Validation

Created `validate_config.sh` to confirm key parameters match expected tuned values.

#### Performance Snapshot

Created `performance_analysis.sh` to summarize:

* CPU info
* memory + pressure
* dirty/writeback status
* network stats + connection summary
* active tuned values
* system load

#### Rollback Safety

Created `rollback_tuning.sh` to restore defaults (with confirmation prompt).
Also documented that removing/renaming the sysctl.d file makes rollback persistent.

#### Continuous Monitoring (prepared)

Created `continuous_monitor.sh` to log key metrics every 60 seconds into `/tmp/performance_log.txt`.
(Prepared for later use; not executed during the lab to avoid a long-running loop.)

---

## ✅ Verification & Validation

This lab is considered complete when:

* Tuned values are active:

  * `sysctl vm.swappiness vm.dirty_ratio vm.vfs_cache_pressure`
  * `sysctl net.core.rmem_max net.core.wmem_max net.core.somaxconn`
* Persistent config exists and loads without error:

  * `/etc/sysctl.d/99-performance-tuning.conf`
  * `sudo sysctl --system`
* Validation script passes:

  * `/tmp/validate_config.sh`
* Monitoring and testing scripts run without failure:

  * `memory_monitor.sh`, `memory_test.sh`
  * `network_monitor.sh`, `network_test.sh`

---

## 📌 Result

At the end of this lab:

* Memory tuning reduced swap aggressiveness and adjusted cache reclaim behavior.
* Network tuning significantly increased buffer limits and queue capacity.
* Tuning was made persistent using sysctl.d configuration.
* I built a safe operational toolkit: validate, analyze, monitor, and rollback.

---

## 🧠 What I Learned

* `/proc/sys` is the live kernel tuning interface; `sysctl` makes it practical to manage
* memory tunables affect swap behavior, writeback timing, and cache reclaim strategy
* network tunables affect throughput, socket buffering, and connection backlog handling
* tuning must be persisted via `/etc/sysctl.d/*.conf` for production readiness
* safe tuning requires validation, logging, and a rollback plan

---

## 🔐 Best Practices & Security Notes (as practiced in this lab)

* Always baseline before changes (monitor + document)
* Change a small set of parameters at a time and validate
* Use `sysctl --system` to verify persistent load order
* Some tunables impact security and stability:

  * verified DoS-related protection example: `net.ipv4.tcp_syncookies = 1`
  * verified memory safety context: `vm.overcommit_memory = 1`
* Keep a rollback mechanism ready before production rollout

---

## ✅ Conclusion

In this lab, I successfully tuned and persisted key Linux kernel parameters using `sysctl`, covering both memory and network optimizations. I validated each change with monitoring and tests, built automation scripts for repeatability, and added rollback and verification tooling to align with production-grade tuning practices.
