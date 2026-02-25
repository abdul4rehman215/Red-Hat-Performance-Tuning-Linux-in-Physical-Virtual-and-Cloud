# 🧪 Lab 02: Setting Up Performance Monitoring Tools

## 🧾 Lab Summary
In this lab, I set up a **performance monitoring toolkit** on **RHEL 9.4** and validated that each tool works for collecting **CPU, memory, disk I/O, and network** performance metrics. I also enabled **sysstat** for automatic system activity collection, ran baseline monitoring tests using multiple utilities, generated controlled system load, and created reusable automation scripts for continuous monitoring and a real-time dashboard.

---

## 🎯 Objectives
By the end of this lab, I was able to:

- Install and configure essential performance monitoring tools on RHEL
- Execute initial performance tests using various monitoring utilities
- Gather and interpret system resource usage data
- Understand the purpose and output of each monitoring tool
- Create baseline performance measurements to support later optimization

---

## ✅ Prerequisites
- Basic Linux CLI knowledge
- Understanding of processes and resource management concepts
- Familiarity with RHEL package management (`dnf`)
- Root/sudo access
- Basic understanding of performance metrics (CPU, memory, disk I/O, network)

---

## 🖥️ Lab Environment
**Environment:** Cloud-based Linux lab VM  
**OS:** Red Hat Enterprise Linux 9.4 (Plow)  
**Access:** sudo/root available  
**Key Tools Installed/Used:**
- `procps-ng` → `top`, `vmstat`
- `sysstat` → `iostat`, `sar`
- `dstat`
- `perf`

---

## 📁 Repository Structure
```text
lab02-setting-up-performance-monitoring-tools/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
└── scripts/
    ├── performance_monitor.sh
    └── performance_dashboard.sh
````

---

## 🧩 Lab Tasks Overview (What I Did)

### ✅ Task 1: Installing Performance Monitoring Tools

#### Subtask 1.1: Update System Packages

* Updated package metadata and ensured the OS was ready for installs.
* Verified OS release version.

#### Subtask 1.2: Install Core Monitoring Tools

Installed and verified the following:

* `procps-ng` (already installed)
* `sysstat` (already installed)
* `dstat` (installed)
* `perf` (installed)

Validated tool locations with:

* `which top vmstat iostat sar dstat perf`

#### Subtask 1.3: Enable System Activity Data Collection

* Enabled and started `sysstat` to support continuous data collection.
* Verified `sysstat` service status.

#### Subtask 1.4: Verify Tool Installation

* Checked versions for: `top`, `vmstat`, `iostat`, `sar`, `dstat`, `perf`.

---

### ✅ Task 2: Running Initial Performance Tests

#### Subtask 2.1: Basic System Overview with `top`

* Ran `top` in batch mode for multiple iterations to observe CPU/memory summary and process list.
* Practiced interactive usage:

  * delayed refresh (`top -d 2`)
  * per-user filtering (`top -u root`)
  * sorting by memory (`top -o %MEM`)

#### Subtask 2.2: Memory and System Statistics with `vmstat`

* Captured one-time snapshot and repeated interval sampling.
* Used MB output mode and summary statistics (`vmstat -s`).

#### Subtask 2.3: Disk I/O Statistics with `iostat`

* Captured disk activity at intervals and reviewed extended metrics (`-x`).
* Attempted device-specific stats (`sda`) and documented the “not found” output (environment uses NVMe device `nvme0n1`).
* Viewed MB-based output mode (`-m`).

#### Subtask 2.4: System Activity Reports with `sar`

* Collected CPU usage (`sar -u`), memory (`sar -r`), network interface stats (`sar -n DEV`), and disk stats (`sar -d`).
* Generated a combined sample collection at intervals.

#### Subtask 2.5: Comprehensive Monitoring with `dstat`

* Used default dstat view and targeted views:

  * CPU/disk/network/memory combined
  * Top CPU and top memory processes
  * Exported monitoring output to a CSV-like file in `/tmp` for later review

#### Subtask 2.6: Advanced Performance Analysis with `perf`

* Listed available perf events (`perf list`)
* Recorded system-wide profile data (`perf record`)
* Generated a report (`perf report`)
* Used live view (`perf top`)
* Recorded a specific event type (`cycles`)

---

### ✅ Task 3: Gathering Resource Usage Data

#### Subtask 3.1: Create System Load for Testing

* Generated CPU load using `yes > /dev/null &` and tracked PID.
* Generated memory and disk activity using `dd`.
* Cleaned up test files and terminated the background CPU load safely.

#### Subtask 3.2: Collect Baseline Performance Data

Saved baseline logs to:

* `~/performance_logs/`
  Collected:
* CPU baseline via `sar`
* Memory baseline via `sar`
* Disk baseline via `iostat -x`
* Network baseline via `sar -n DEV`

#### Subtask 3.3: Create a Performance Monitoring Script

Created an automation script to gather:

* CPU (`sar -u`)
* Memory (`sar -r`)
* Disk I/O (`iostat -x`)
* Network (`sar -n DEV`)
* Combined system data to CSV (`dstat --output ...`)
  This script supports a duration parameter in minutes.

#### Subtask 3.4: Analyze Collected Data

* Listed the generated logs.
* Viewed summaries using `tail` for CPU, memory, and disk outputs.

#### Subtask 3.5: Create a Performance Dashboard Script

Created a real-time “dashboard” script that displays:

* CPU usage snapshot
* Memory and swap summary
* Disk usage
* Load averages
* Top CPU consumers
  Auto-refreshes every 5 seconds until Ctrl+C.

---

## ✅ Verification & Validation

I validated the lab setup by confirming:

* Tools exist and run successfully:

  * `top`, `vmstat`, `iostat`, `sar`, `dstat`, `perf`
* `sysstat` service enabled and started:

  * `systemctl status sysstat`
* Baseline logs created under:

  * `~/performance_logs/`
* Monitoring scripts exist and are executable:

  * `~/performance_monitor.sh`
  * `~/performance_dashboard.sh`

---

## 📌 Result

At the end of this lab:

* Performance monitoring tooling was installed and verified on RHEL 9.4
* sysstat collection was enabled for ongoing activity reporting
* Baseline performance logs were collected for CPU/memory/disk/network
* `dstat` exports and `perf` profiling were successfully tested
* Reusable monitoring + dashboard scripts were created for future labs

---

## 🧠 What I Learned

* Performance tuning starts with reliable **observability** and baseline data
* `sar` and `iostat` become more useful once sysstat data collection is active
* `dstat` is excellent for combined multi-metric snapshots and exporting logs
* `perf` provides deeper CPU-level insight for advanced tuning and profiling
* Automating monitoring improves consistency and reduces manual effort

---

## 🌍 Why This Matters

Having proper monitoring tools in place enables:

* Proactive detection of bottlenecks before users are impacted
* Capacity planning using measured resource trends
* Faster troubleshooting with objective metrics
* Data-driven tuning decisions rather than guesswork

---

## ✅ Conclusion

In this lab, I successfully installed and validated essential performance monitoring tools (`top`, `vmstat`, `iostat`, `sar`, `dstat`, `perf`) on RHEL 9.4, enabled sysstat for performance data collection, executed initial tests to understand tool outputs, collected baseline logs, and built reusable monitoring and dashboard scripts. This monitoring foundation supports advanced tuning tasks in later labs and mirrors real-world performance engineering workflows.
