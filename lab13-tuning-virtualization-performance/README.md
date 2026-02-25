# 🧪 Lab 13: Tuning Virtualization Performance

> **Focus:** Improving VM performance on a KVM/libvirt host by tuning **vCPU topology + pinning**, enabling **hugepages + NUMA-aware memory**, implementing **memory ballooning**, running **load tests**, and validating improvements with benchmarks + reports.

---

## 📌 Lab Summary

In this lab, I tuned virtualization performance on an Ubuntu KVM host using **libvirt (virsh)** and common performance tooling. The workflow followed an enterprise-style approach:

1. **Baseline VM discovery and configuration review** (vCPU + memory)
2. **vCPU tuning** (host CPU topology awareness, vCPU pinning, host-passthrough)
3. **Memory optimization** (hugepages, NUMA tuning, memory backing controls)
4. **Memory ballooning** (virtio balloon driver + VM device configuration)
5. **Automated memory balancing** (policy-based resource adjustments + cron)
6. **Performance validation under load** (stress-ng + sysbench + combined benchmark)
7. **Reporting** (benchmark summary + virtualization performance report)

This lab simulates real-world tasks performed by platform engineers and cloud/virtualization admins responsible for stable high-performance VM workloads.

---

## 🎯 Objectives

By the end of this lab, I was able to:

- Configure optimal vCPU allocation strategies for virtual machines
- Implement memory ballooning to improve overall host memory efficiency
- Monitor and analyze VM performance metrics using `virsh` and system tools
- Apply best practices for KVM/libvirt tuning (pinning, hugepages, NUMA)
- Validate performance behavior under load conditions (CPU + memory + I/O)
- Troubleshoot common virtualization performance bottlenecks (services, memory, CPU)

---

## ✅ Prerequisites

- Linux system administration basics
- CLI comfort (editing, package install, scripts)
- Virtualization fundamentals (hypervisor, VM resources, guest drivers)
- Performance monitoring knowledge (CPU/memory baselines and interpretation)
- Previous labs in the performance tuning series recommended

---

## 🧰 Lab Environment

- **Platform:** Cloud lab VM acting as **KVM Host**
- **Host:** `toor@ip-172-31-10-233`
- **OS:** Ubuntu 24.04.1 LTS
- **Hypervisor:** KVM/QEMU + libvirt (`virsh`)
- **Host Resources:** 8 vCPUs, 16GB RAM (as provisioned)
- **Existing VMs:** vm-test1 (running), vm-test2 (off), perf-sample (off)
- **New VM Created:** `performance-vm` (configured for performance tuning tests)

> Note: Some packages were already installed; missing tooling was verified and installed where necessary.

---

## 🗂️ Repository Structure

```text
lab13-tuning-virtualization-performance/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
├── scripts/
│   ├── configure_vcpu.sh
│   ├── update_memory.sh
│   ├── setup_ballooning.sh
│   ├── monitor_balloon.sh
│   ├── adjust_memory.sh
│   ├── auto_balance.sh
│   ├── install_perf_tools.sh
│   ├── cpu_stress_test.sh
│   ├── analyze_cpu_results.sh
│   ├── memory_stress_test.sh
│   ├── analyze_memory_results.sh
│   ├── comprehensive_benchmark.sh
│   ├── summarize_results.sh
│   ├── performance_comparison.sh
│   └── generate_report.sh
└── configs/
    ├── memory_config.xml
    └── balloon_config.xml
````

---

## ✅ Tasks Overview

### **Task 1: Configure vCPU and Memory Settings for VMs**

#### **Subtask 1.1: Analyze Current VM Configuration**

* Listed all VMs and verified baseline state
* Extracted current vCPU and memory settings from VM XML
* Reviewed VM resource allocation using `virsh dominfo`

#### **Subtask 1.2: Configure Optimal vCPU Settings**

* Inspected host CPU topology (`lscpu`, `/proc/cpuinfo`)
* Created a performance VM with tuned CPU topology using `virt-install`:

  * 4 vCPUs (max 8), socket/core/thread topology aligned
  * `--cpu host-passthrough`
* Applied vCPU pinning (affinity) for cache locality and consistent performance:

  * pinned vCPU 0–3 to physical CPUs 0–3
* Verified pinning with `virsh vcpuinfo`

#### **Subtask 1.3: Optimize Memory Configuration**

* Created NUMA-aware memory backing settings:

  * hugepages, no share pages, locked memory
  * strict NUMA node binding
* Reserved hugepages at host level (2GB using 1024×2MB hugepages)
* Updated VM XML via `virsh edit` to include memory backing and numatune elements

---

## ✅ Task 2: Memory Ballooning Optimization

### **Subtask 2.1: Enable Memory Ballooning**

* Loaded `virtio_balloon` driver inside guest
* Ensured module persists across reboot (`/etc/modules`)
* Added virtio balloon device to VM using `virsh attach-device --config`
* Verified balloon device exists in VM XML

### **Subtask 2.2: Monitor and Control Ballooning**

* Built monitoring script combining:

  * host memory (`free -h`)
  * VM memory stats (`virsh dommemstat`, `virsh domstats --balloon`)
* Adjusted live VM memory target via `virsh setmem --live`
* Confirmed change using dommemstat output

### **Subtask 2.3: Implement Automatic Memory Balancing**

* Built a basic policy-based script:

  * reduce VM memory if host memory usage >80%
  * increase VM memory if host memory usage <50%
  * enforce min/max boundaries
* Logged changes to `/var/log/memory_balancing.log`
* Automated execution using cron every 5 minutes

---

## ✅ Task 3: VM Performance Testing Under Load

### **Subtask 3.1: Install Performance Tools**

* Installed or verified: stress-ng, sysbench, fio, iperf3, sysstat, htop, iotop, collectl, nmon
* Built a helper installer script that installs a full toolkit (including netperf, memtester)

### **Subtask 3.2: CPU Performance Testing**

* Ran stress-ng CPU load test (5 minutes)
* Logged before/during/after CPU metrics with:

  * `virsh domstats --cpu`
  * `top`
* Generated an analysis summary script to review results

### **Subtask 3.3: Memory Performance Testing**

* Ran stress-ng memory workload and captured:

  * VM memory stats (dommemstat)
  * host memory snapshots (free -h)
* Confirmed ballooning-related values changing under load
* Generated analysis summary script

### **Subtask 3.4: Comprehensive Benchmark**

* Built a multi-stage benchmark:

  * sysbench CPU
  * sysbench memory
  * sysbench fileio (prepare/run/cleanup)
  * combined stress-ng (cpu/vm/io)
* Stored outputs under `/tmp/benchmark_results`
* Generated a summary report from latest benchmark logs

### **Subtask 3.5: Validation Report**

* Produced a quick “optimized results” comparison log using sysbench and domstats
* Generated a complete virtualization performance report with tuning summary + benchmark output

---

## 🧪 Validation & Evidence

Validation evidence included:

* `virsh dominfo`, `virsh dumpxml` checks for resource configuration
* `virsh vcpuinfo` pinning verification
* hugepages reservation verified via `/proc/meminfo`
* balloon device present in XML + balloon stats visible via `virsh domstats --balloon`
* benchmark artifacts created under:

  * `/tmp/perf_logs`
  * `/tmp/benchmark_results`
  * `/tmp/performance_comparison`
* performance report generated:

  * `/tmp/virtualization_performance_report.txt`

All captured output is included in `output.txt`.

---

## 🧠 What I Learned

* How host CPU topology affects VM CPU efficiency and predictability
* Why vCPU pinning improves cache locality and reduces scheduling jitter
* How hugepages reduce TLB misses and improve memory performance for VMs
* Practical ballooning workflow: guest driver + virtio device + live setmem
* How to automate a simple memory balancing policy safely
* How to validate tuning effects using repeatable CPU/memory/I/O benchmarks

---

## 🌍 Why This Matters

Virtualization performance tuning is critical in modern infrastructure where multiple workloads compete for limited host resources. These techniques help:

* **Reduce costs** through better consolidation and utilization
* **Improve application performance** and reduce latency spikes
* **Increase stability** by preventing resource contention bottlenecks
* **Improve scalability** with predictable resource allocations

This skillset directly maps to cloud, DevOps, SRE, and infrastructure engineering roles.

---

## ✅ Conclusion

In this lab, I:

✅ Tuned vCPU settings with topology alignment + pinning
✅ Enabled hugepages + NUMA-aware memory backing
✅ Implemented memory ballooning and validated control using virsh
✅ Automated memory balancing with policy logic + cron scheduling
✅ Tested performance under CPU/memory/I/O load using stress-ng + sysbench
✅ Generated benchmark summaries and a virtualization performance report

---
