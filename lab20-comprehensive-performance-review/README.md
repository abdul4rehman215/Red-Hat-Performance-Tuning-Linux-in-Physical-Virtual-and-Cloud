# 🧪 Lab 20: Comprehensive Performance Review

## 📌 Overview
This lab is a **full-system performance review** where we monitored **CPU, memory, disk I/O, and network** *together* (not one tool at a time), identified bottlenecks from real data, applied safe tuning, and validated changes with before/after testing.

---

## 🎯 Objectives
- ✅ Perform holistic performance analysis using multiple tools simultaneously
- ✅ Identify bottlenecks across **CPU, Memory, Disk I/O, Network**
- ✅ Apply tuning changes based on measured evidence
- ✅ Document changes and validate optimization effectiveness
- ✅ Build a repeatable workflow for production performance reviews

---

## ✅ Prerequisites
- Linux CLI basics (navigation, permissions, editors)
- Understanding of CPU / Memory / Disk / Network metrics
- Familiarity with monitoring concepts from previous labs
- Sudo/root access for tuning changes
- Basic shell scripting knowledge

---

## 🖥️ Lab Environment
**Ubuntu Cloud Lab**
- **Machine:** `toor@ip-172-31-10-267`
- **OS:** Ubuntu 24.04.1 LTS
- **CPU:** 2 vCPU (burstable cloud profile)
- **RAM:** 4GB
- **NIC:** `ens5`

---

## 🧩 Tools Used
- **CPU / Process:** `top`, `htop`
- **Disk I/O:** `iostat`
- **System Activity:** `sar`
- **System Snapshot:** `free`, `df`, `uptime`
- **Scheduling / Memory pressure:** `vmstat`
- **Benchmarking:** `dd`, `iperf3`
- **Scripting + reports:** Bash scripts + timestamped logs

---

## 🧪 Task Summary (High-Level)
### 🟦 Task 1: Baseline + Concurrent Monitoring
- Created a workspace under `/opt/performance-review`
- Captured **system baseline info**
- Ran a **5-minute monitoring window** collecting:
  - `top`, `iostat`, `sar`, `vmstat`, periodic `free`
- Stored outputs in **timestamped folders** for repeatability

### 🟩 Task 2: Data Analysis + Bottleneck Identification
- Parsed collected logs to compute:
  - Avg CPU usage + top CPU processes
  - Avg disk utilization + high-util devices
  - Avg memory usage
  - Avg network RX/TX
- Verified tunables (swappiness, dirty ratios, scheduler, TCP settings)

### 🟨 Task 3: Apply Data-Driven Tuning
Applied tuning safely (with backups + persistent config):
- Memory tuning:
  - `vm.swappiness = 10`
  - `vm.dirty_ratio = 15`
  - `vm.dirty_background_ratio = 5`
- Network buffers:
  - `net.core.rmem_max = 16777216`
  - `net.core.wmem_max = 16777216`
- TCP:
  - `net.ipv4.tcp_window_scaling = 1`
- Created persistence file:
  - `/etc/sysctl.d/99-performance-tuning.conf`

### 🟥 Task 4: Post-Tuning Validation + Documentation
- Ran post-tuning tests for:
  - CPU task timing
  - Memory write speed (`dd`)
  - Disk write/read throughput (`dd`)
  - Network loopback (`iperf3`)
- Generated **comparison report** (baseline vs post-tuning)
- Documented the tuning + validation notes

---

## 📊 Results Summary
- Monitoring produced actionable evidence:
  - CPU spikes during stress window
  - High disk utilization on `nvme0n1` during I/O stress
  - Memory usage average around ~60% during workload
- After tuning:
  - Lower swappiness reduces unnecessary swap tendency
  - Lower dirty ratios improve writeback behavior (more responsive under I/O pressure)
  - Increased network buffers improve throughput stability
  - Persistent config ensures settings survive reboot

---

## 🧠 What I Learned
- ✅ One tool alone can lie — **correlation across tools** reveals the real bottleneck.
- ✅ Collecting data **during real load** is mandatory for meaningful tuning.
- ✅ Always apply tuning with:
  - backups
  - verification
  - persistence strategy
- ✅ “Before/After” must be **apples-to-apples** (same stress test window) for production.

---

## 🌍 Why This Matters
In production, performance issues rarely belong to one subsystem.
This workflow helps teams:
- prevent random tuning guesses
- find real root causes
- validate improvements safely
- maintain documentation and rollback plans

---

## 🏢 Real-World Relevance
- SRE/DevOps incident response (slow apps, spikes, saturation)
- Capacity planning and baseline building
- Cloud cost optimization (right-sizing based on metrics)
- Post-change validation after system upgrades/tuning
- Auditable performance reviews for production servers

---

## 📁 Repo Structure
```bash
lab20-comprehensive-performance-review/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
├── baseline/
│   └── system_info.txt
├── monitoring/
│   └── <timestamp>/
│       ├── top_output.txt
│       ├── iostat_output.txt
│       ├── sar_output.txt
│       ├── vmstat_output.txt
│       └── memory_tracking.txt
├── reports/
│   ├── performance_analysis_<timestamp>.txt
│   └── performance_comparison_<timestamp>.txt
└── scripts/
    ├── performance_monitor.sh
    ├── cpu_stress.sh
    ├── io_stress.sh
    ├── analyze_performance.sh
    ├── identify_bottlenecks.sh
    ├── tuning_recommendations.sh
    ├── apply_tuning.sh
    ├── verify_tuning.sh
    ├── post_tuning_test.sh
    └── compare_performance.sh
````

---

## ✅ Conclusion

This lab completed a full **end-to-end performance review cycle**:
**baseline → monitor → analyze → tune → verify → validate → document**.

By combining multiple monitoring tools, we avoided guesswork and applied tuning changes backed by measurable system behavior—exactly how performance reviews should be done in real production environments.

