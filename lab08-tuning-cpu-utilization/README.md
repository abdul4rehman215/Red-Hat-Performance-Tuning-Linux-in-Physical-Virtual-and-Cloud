# 🧪 Lab 08: Tuning CPU Utilization

**Environment:** Ubuntu 20.04+ (Cloud Lab Environment)  
**User:** `toor`  
**Focus:** CPU scheduler tuning (`sysctl`), CPU affinity (`taskset`), CPU monitoring & benchmarking (`stress-ng`, `mpstat`, `vmstat`, `iostat`)

---

## 🎯 Objectives

By the end of this lab, I was able to:

- Understand **Linux CPU scheduling concepts** and key scheduler parameters
- Modify CPU scheduler tunables using **sysctl**
- Configure **CPU affinity** for processes to improve cache locality and utilization
- Monitor CPU utilization metrics effectively using standard Linux tooling
- Apply tuning techniques to optimize **CPU-bound workloads**
- Troubleshoot common CPU performance issues in production-like environments

---

## ✅ Prerequisites

- Basic Linux CLI usage
- Process management basics: `ps`, `top`, `htop`
- Understanding of CPU architecture: **cores / threads / scheduling**
- Root or sudo privileges (for `sysctl` edits and persistence)

---

## 🧰 Lab Summary

This lab was executed in a cloud VM (EC2-style), so storage devices were NVMe (`nvme0n1`) instead of `sda`—this mattered for a few “scheduler path” checks.

### What I did in this lab

#### ✅ Task 1: CPU Scheduler Tuning (sysctl)
- Checked baseline scheduler-related tunables using:
  - `sysctl -a | grep sched`
  - `/proc/schedstat`
  - `lscpu`
- Captured a **backup** of existing scheduler settings in:
  - `/tmp/original_sched_settings.txt`
- Tuned scheduler parameters for improved scheduling responsiveness/throughput tradeoffs:
  - `kernel.sched_min_granularity_ns`
  - `kernel.sched_wakeup_granularity_ns`
  - `kernel.sched_migration_cost_ns`
  - `kernel.sched_latency_ns`
- Made tuning **persistent** by appending a block into:
  - `/etc/sysctl.conf`
- Validated changes via `sysctl` reads and re-ran stress tests to compare results.

#### ✅ Task 2: CPU Affinity Optimization (taskset)
- Verified CPU topology and affinity masks:
  - `lscpu -e`
  - `taskset -p <PID>`
  - Installed `numactl` when missing and reviewed:
    - `numactl --hardware`
- Built CPU and memory workload generators:
  - `cpu_intensive.py`
  - `memory_intensive.py`
- Compared behavior:
  - Default affinity (`mask f` / all cores)
  - Optimized affinity (split CPU-heavy tasks across dedicated cores)
- Built a monitoring loop using:
  - `mpstat`, `vmstat`, `free`, `uptime`
- Demonstrated advanced technique:
  - **Dynamic affinity changes** while the process is running (`taskset -cp`)

#### ✅ Task 3: Performance Testing + Profiles
- Created a complete benchmark framework:
  - `cpu_performance_test.sh` → captures results into `cpu_performance_results.log`
- Simulated a “real-world” CPU-heavy app:
  - `web_server_sim.py` (threaded workload)
- Compared performance across:
  - Default scheduling
  - Full-core binding
  - Over-restricting to fewer cores (reduced throughput — realistic outcome)
- Created reusable “optimization profiles”:
  - `optimization_profiles.sh` (throughput / latency / balanced)

---

## 📌 Key Results (as observed)

- Scheduler tuning showed a **small but realistic improvement** in `stress-ng` ops/s.
- CPU affinity validation confirmed correct masks:
  - `0,1` → mask `3`
  - `2,3` → mask `c`
  - `0-3` → mask `f`
- Web server simulation results were realistic:
  - Full-core affinity slightly improved throughput
  - Constraining 4 busy workers to only 2 cores reduced throughput significantly

---

## 🌍 Why This Matters (Real-World Relevance)

CPU tuning is critical in production systems where:
- High context switching reduces throughput
- Poor CPU placement increases cache misses and latency
- CPU contention impacts web servers, databases, CI runners, build systems, and data pipelines

Practical use cases:
- Pinning latency-sensitive workloads to dedicated cores
- Reducing scheduler overhead in high-concurrency environments
- Improving throughput for CPU-bound services and batch jobs
- Preparing systems for performance-sensitive deployments in cloud environments

---

## ✅ Validation Checklist

You can confirm lab completion by checking:

- Scheduler values applied:
  - `sysctl kernel.sched_min_granularity_ns`
  - `sysctl kernel.sched_wakeup_granularity_ns`
  - `sysctl kernel.sched_migration_cost_ns`
  - `sysctl kernel.sched_latency_ns`
- Affinity applied correctly:
  - `taskset -p <PID>`
- Benchmark artifacts exist:
  - `cpu_performance_results.log`
  - `performance_analysis.txt`
- Scripts are executable:
  - `chmod +x *.sh`

---

## 📁 Repo Structure (Lab 08)

```text
lab08-tuning-cpu-utilization/
├── README.md
├── commands.sh
├── scripts/
│   ├── cpu_stress_test.sh
│   ├── cpu_intensive.py
│   ├── memory_intensive.py
│   ├── manage_affinity.sh
│   ├── monitor_performance.sh
│   ├── dynamic_affinity.sh
│   ├── cpu_performance_test.sh
│   ├── web_server_sim.py
│   ├── analyze_performance.sh
│   └── optimization_profiles.sh
├── output.txt
├── interview_qna.md
└── troubleshooting.md
````

---

## 📌 Notes

* This lab uses **Ubuntu 20.04+**, and some cloud VMs may **not expose** CPU governor paths under:

  * `/sys/devices/system/cpu/cpu*/cpufreq/`
* NVMe disks appear under `/sys/block/nvme0n1/...` instead of `/sys/block/sda/...`

